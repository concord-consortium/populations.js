import EnvironmentView from '../views/environment-view';
import StateMachine from '../state-machine';
import * as helpers from '../helpers';
import Events from '../events';

const SEASONS = ["spring", "summer", "fall", "winter"];

const defaultOptions = {
 //columns         :   # not defined because it may conflict with width
 //rows            :
 //width           :   # not defined because it may conflict with columns
 //height          :
  imgPath         : "",
  winterImgPath   : null,
  barriers        : [],
  wrapEastWest    : false,
  wrapNorthSouth  : false,
  seasonLengths   : [],      // optionally the lengths of [spring, summer, fall, winter]
  depthPerception : false   // sort agents so that agents on the bottom are drawn on top of agents on the top
};

const cellDefaults = {
  'food'               : 100,
  'food animals'       : 100,
  'food full'          : 100,
  'food low'           :  30,
  'food regrowth rate' :   3
};

//Other options also accessible by @get
// season          :   # set by seasonsLength
// yearLength      :   # set by seasonsLength

export default class Environment extends StateMachine {

  constructor(opts) {
    super();

    /* Default properties */

    this._columnWidth = 10;
    this._rowHeight =   10;
    this._rules = null;
    this._speed = 50;
    this._runLoopDelay = 54.5;

    this._isRunning = false;

    this._listeners = [];

    /* UI States */

    this.UI_STATE = {
      NONE: "None",
      ADD_AGENTS: "Add Agents"
    };

    opts = helpers.setDefaults(opts, defaultOptions);
    for (let prop in opts) { this[prop] = opts[prop]; }     // give us immediate access to @columns, @barriers, etc

    this.preload = [];
    if (this.imgPath) { this.preload.push(this.imgPath); }
    if (this.winterImgPath) { this.preload.push(this.winterImgPath); }

    if (this.columns && this.width) {
      throw new Error("You can set columns and rows, or width and height, but not both");
    }
    if (this.columns) {
      this.width = this.columns * this._columnWidth;
      this.height = this.rows * this._rowHeight;
    }
    if (this.width) {
      if (!((this.width % this._columnWidth) === 0)) {
        throw new Error(`Width ${this.width} is not evenly divisible by the column width ${this._columnWidth}`);
      }
      if (!((this.height % this._rowHeight) === 0)) {
        throw new Error(`Height ${this.height} is not evenly divisible by the row height ${this._rowHeight}`);
      }
      this.columns = this.width / this._columnWidth;
      this.rows = this.height / this._rowHeight;
    }

    let viewWidth = opts.viewWidth;
    let viewHeight = opts.viewHeight;
    if (viewWidth && !viewHeight) {
      viewHeight = this.height * (this.viewWidth / this.width);
    } else if (viewHeight && !viewWidth) {
      viewWidth = this.width * (this.viewHeight / this.height);
    }

    this.viewWidth = viewWidth || this.width;
    this.viewHeight = viewHeight || this.height;

    this.cells = [];
    for (let col = 0; col < this.columns; col++) {
      this.cells[col] = [];
    }

    this._setCellDefaults();

    this._runLoopDelay = Environment.DEFAULT_RUN_LOOP_DELAY;

    this.setBarriers(this.barriers);

    this.agents = [];
    this._rules = [];

    this.carriedAgent = null;

    this._remapSeasonLengths();

    this.season = SEASONS[0];
    this.date   = 0;

    // Add User Interaction states
    this.addState(this.UI_STATE.NONE, EmptyState);
    this.addState(this.UI_STATE.ADD_AGENTS, AddAgentsState);

    this._view = new EnvironmentView({environment: this});

    this.setState(this.UI_STATE.NONE);
  }

  /* Public API */

  addAgent(agent){
    agent.environment = this;
    const loc = this.ensureValidLocation(agent.getLocation());
    agent.setLocation(loc);
    if (this.isInBarrier(loc.x, loc.y)) {
      return false;
    }

    const col = Math.floor(loc.x / this._columnWidth);
    const row = Math.floor(loc.y / this._rowHeight);
    const agents = this.get(col, row, "num agents");
    if ((agents == null)) {
      this.set(col, row, "num agents", 1);
    } else {
      this.set(col, row, "num agents", agents+1);
    }

    if (this.agents.indexOf(agent) === -1) {
      this.agents.push(agent);
      Events.dispatchEvent(Environment.EVENTS.AGENT_ADDED, {agent});
      return true;
    }
    return false;
  }

  removeAgent(agent){
    const loc = agent.getLocation();
    const col = Math.floor(loc.x / this._columnWidth);
    const row = Math.floor(loc.y / this._rowHeight);
    const agents = this.get(col, row, "num agents");
    if ((agents == null)) {
      this.set(col, row, "num agents", 0);
    } else {
      this.set(col, row, "num agents", agents-1);
    }

    if (this.agents.removeObj(agent)) { return this.getView().removeAgent(agent); }
  }

  removeDeadAgents() {
    let i = 0;
    while (i < this.agents.length) {
      const a = this.agents[i];
      if (a.isDead) {
        this.removeAgent(a);
      } else {
        i++;
      }
    }
  }

  agentsWithin({x,y,width,height}){
    if ((x == null) || (y == null) || (width == null) || (height == null)) { throw new Error("Invalid rectangle definition!"); }
    const area = new Barrier(x,y,width,height);
    const found = [];
    for (let agent of this.agents) {
      const loc = agent.getLocation();
      if (area.contains(loc.x, loc.y)) { found.push(agent); }
    }

    return found;
  }

  ensureValidLocation({x,y}) {
    x = this.wrapEastWest   ? this._wrapSingleDimension(x,  this.width) : this._bounceSingleDimension(x,  this.width);
    y = this.wrapNorthSouth ? this._wrapSingleDimension(y, this.height) : this._bounceSingleDimension(y, this.height);

    return {x,y};
  }

  randomLocation() {
    return this.randomLocationWithin(0,0,this.width,this.height);
  }

  randomLocationWithin(left, top, width, height, avoidBarriers){
    if (avoidBarriers == null) { avoidBarriers = false; }
    let point = {x: helpers.ExtMath.randomInt(width)+left, y: helpers.ExtMath.randomInt(height)+top};
    while (avoidBarriers && this.isInBarrier(point.x, point.y)) {
      point = {x: helpers.ExtMath.randomInt(width)+left, y: helpers.ExtMath.randomInt(height)+top};
    }
    return point;
  }

  set(col, row, prop, val) {
    if (!this.cells[col][row]) {
      this.cells[col][row] = {};
    }

    this.cells[col][row][prop] = val;
  }

  get(col, row, prop) {
    // get global properties first
    if (this[prop]) {
      return this[prop];
    }
    if (!this.cells[col][row]) {
      return null;
    }

    return this.cells[col][row][prop];
  }

  getAt(x, y, prop) {
    const col = Math.floor(x / this._columnWidth);
    const row = Math.floor(y / this._rowHeight);
    return this.get(col, row, prop);
  }

  setAt(x, y, prop, val) {
    const col = Math.floor(x / this._columnWidth);
    const row = Math.floor(y / this._rowHeight);
    this.set(col, row, prop, val);
  }

  getAgentsAt(x,y){
    const agents = [];
    for (let agent of this.agents) {
      if (agent.getView().contains(x,y)) {
        agents.push(agent);
      }
    }
    return agents;
  }

  getAgentAt(x,y){
    for (let agent of this.agents) {
      if (agent.getView().contains(x,y)) {
        return agent;
      }
    }
    return null;
  }

  getAgentsCloseTo(x, y, maxDistance, speciesName){
    if (maxDistance == null) { maxDistance = 10; }
    const area = {x: x - maxDistance, y: y - maxDistance, width: maxDistance*2, height: maxDistance*2};
    let agents = this.agentsWithin(area);
    if (!agents.length) { return []; }
    if (speciesName) {
      const _agents = [];
      for (let agent of agents) {
        if (agent.species.speciesName === speciesName) { _agents.push(agent); }
      }
      agents = _agents;
    }
    return agents;
  }

  getAgentCloseTo(x, y, maxDistance, speciesName){
    if (maxDistance == null) { maxDistance = 10; }
    let agents = this.getAgentsCloseTo(x, y, maxDistance, speciesName);
    if (!agents.length) { return null; }
    for (let agent of agents) {
      agent.__distance = helpers.ExtMath.distanceSquared(agent.getLocation(), {x, y});
    }
    agents = agents.sort((a,b)=> a.__distance - b.__distance);
    return agents[0];
  }

  /**
   * Returns an object containing each of the closest orgs by species name. E.g.
   *
   * {
   *  rabbits: RabbitAgent,
   *  plants: PlantAgent
   * }
  */
  getAgentsOfEachSpeciesCloseTo(x, y, maxDistance){
    if (maxDistance == null) { maxDistance = 10; }
    let agents = this.getAgentsCloseTo(x, y, maxDistance);

    const foundAgents = {};
    if (!agents.length) { return foundAgents; }

    for (let agent of agents) {
      agent.__distance = helpers.ExtMath.distanceSquared(agent.getLocation(), {x, y});
    }
    agents = agents.sort((a,b)=> a.__distance - b.__distance);

    for (let agent of agents) {
      if (!foundAgents[agent.species.speciesName]) {
        foundAgents[agent.species.speciesName] = agent;
      }
    }
    return foundAgents;
  }

  setBarriers(bars){
    const barriers = bars.slice();
    this.barriers = [];
    for (let barrier of (barriers || [])) {
      this.addBarrier.apply(this, barrier);
    }
    if (this._view && (this._view.barrierGraphics)) {
      this._view.rerenderBarriers();
    }
  }

  addBarrier(x, y, width, height) {
    this.barriers.push(new Barrier(x, y, width, height));
  }

  crossesBarrier(start, finish){
    let line;
    if ((!this.wrapEastWest && ((0 > finish.x) || (finish.x > this.width))) ||
        (!this.wrapNorthSouth && ((0 > finish.y) || (finish.y > this.height)))) {
      return true;
    }

    const dx = finish.x - start.x;
    const dy = finish.y - start.y;
    if (dx !== 0) {
      const m = dy/dx;
      line = (x,y)=> ((m * (x - start.x)) + start.y) - y;
    } else {
      line = (x,y)=> x - start.x;
    }
    for (let barrier of this.barriers) {
      if (barrier.contains(finish.x, finish.y)) { return true; }
      if (((start.x > barrier.x2) && (finish.x > barrier.x2)) || // entirely to the right
                  ((start.x < barrier.x1) && (finish.x < barrier.x1)) || // entirely to the left
                  ((start.y > barrier.y2) && (finish.y > barrier.y2)) || // entirely below
                  ((start.y < barrier.y1) && (finish.y < barrier.y1))) { continue; }    // entirely above
      if (barrier.intersectsLine(line)) { return true; }
    }
    return false;
  }

  setSeasonLength(season, length){
    let idx = -1;
    switch (season) {
      case "spring":case 0: idx = 0; break;
      case "summer":case 1: idx = 1; break;
      case "fall":case 2: idx = 2; break;
      case "winter":case 3: idx = 3; break;
      default: throw new Error(`Invalid season '${season}'`);
    }

    this.seasonLengths[idx] = length;
    this._remapSeasonLengths();
  }

  isInBarrier(x, y) {
    for (let barrier of this.barriers) {
      if (barrier.contains(x, y)) {
        return true;
      }
    }
    return false;
  }

  pickUpAgent(agent) {
    this.removeAgent(agent);
    this.carriedAgent = agent;
  }

  dropCarriedAgent() {
    if (!this.addAgent(this.carriedAgent)) {
      // drop the agent back on it's original location if addAgent returns false
      this.carriedAgent.setLocation(this._agentOrigin);
      this.addAgent(this.carriedAgent);
    }
    this.getView().removeCarriedAgent(this.carriedAgent);
    this.carriedAgent = null;
  }

  // Used for setting the default species and traits for
  // creating and adding agents.
  setDefaultAgentCreator(defaultSpecies, defaultTraits, agentAdderCallback) {
    this.defaultSpecies = defaultSpecies;
    this.defaultTraits = defaultTraits;
    this.agentAdderCallback = agentAdderCallback;
  }

  addDefaultAgent(x, y) {
    if (this.defaultSpecies == null) { return; }
    const agent = this.defaultSpecies.createAgent(this.defaultTraits);
    agent.environment = this;
    agent.setLocation({x, y});
    const success = this.addAgent(agent);
    if (success && this.agentAdderCallback) {
      this.agentAdderCallback();
    }
  }

  addMouseListener(callback, getNearestAgents, distance) {
    callback.getNearestAgents = getNearestAgents;
    callback.distance = distance || 10;
    this._listeners.push(callback);
  }

  notifyListeners(evt) {
    let closestAgents;
    this._listeners.forEach( callback => {
      if (callback.getNearestAgents) {
        if (!closestAgents) {
          closestAgents = this.getAgentsOfEachSpeciesCloseTo(evt.envX, evt.envY, callback.distance);
        }
        evt.agents = closestAgents;
        callback(evt);
      } else {
        callback(evt)
      }
    });
  }

  /* Run Loop */

  // Speed is a value between 0 and 100, 0 being slow and 100 being fast.
  // The default is 50.
  setSpeed(speed){
    this._speed = speed;
    // fps curve that looks like this:
    // http://fooplot.com/#W3sidHlwZSI6MCwiZXEiOiIoLTEvKCh4LTE0MSkvNDAwMCkpLTI3LjMiLCJjb2xvciI6IiMwMDAwMDAifSx7InR5cGUiOjEwMDAsIndpbmRvdyI6WyIwIiwiMTAwIiwiMCIsIjgwIl19XQ--
    const fps = (-1/((speed-141)/4000))-27.3;
    const delay = 1000/fps;
    this._runLoopDelay = delay;
  }

  start() {
    this._isRunning = true;
    var runloop = () => {
      setTimeout(() => {
        this.step();
        if (this._isRunning) {
          runloop();
        }
      }
      , this._runLoopDelay);
    };

    runloop();
    Events.dispatchEvent(Environment.EVENTS.START, {});
  }

  stop() {
    this._isRunning = false;
    Events.dispatchEvent(Environment.EVENTS.STOP, {});
  }

  step() {
    let a;
    this._incrementDate();
    // Apply all of the rules
    for (let r of this._rules) {
      for (a of this.agents) {
        r.execute(a);
      }
    }
    for (a of this.agents) {
      if (a._consumeResources) { a._consumeResources(); }
      a.step();
    }
    this._replenishResources();
    this.removeDeadAgents();
    Events.dispatchEvent(Environment.EVENTS.STEP, {});
  }

  reset() {
    this.stop();
    let i = this.agents.length;
    while (i) { this.removeAgent(this.agents[--i]); }
    this.date   = 0;
    Events.dispatchEvent(Environment.EVENTS.RESET, {});
  }

  /* Getters and Setters */

  getView() {
    return this._view;
  }

  addRule(rule){
    if (!this._rules) { this._rules = []; }
    if (this._rules.indexOf(rule) === -1) {
      this._rules.push(rule);
    }
  }

  removeRule(rule){
    if (!this._rules) { this._rules = []; }
    this._rules.removeObj(rule);
  }

  clearRules() {
    this._rules = [];
  }

  setBackground(path){
    this.imgPath = path;
    this._view.updateBackground();
  }

  _incrementDate() {
    this.date++;
    if (this.usingSeasons && (this._totalSeasonLengths.length === 4)) {
      const yearDate = this.date % this.yearLength;
      for (let i = 0; i < this._totalSeasonLengths.length; i++) {
        const length = this._totalSeasonLengths[i];
        if (yearDate < length) {
          if (this.season !== SEASONS[i]) {
            this.season = SEASONS[i];
            Events.dispatchEvent(Environment.EVENTS.SEASON_CHANGED, {season: this.season});
          }
          break;
        }
      }

      if (yearDate === this._totalSeasonLengths[2]) { // first day of winter
        this._view.addWinterImage();
      } else if (yearDate === (this._totalSeasonLengths[3]-1)) { // last day of winter
        this._view.removeWinterImage();
      }
    }
  }

  _replenishResources() {
    this.cells.forEach( column => {
      column.forEach( cell => {
        const growthRate = cell['food regrowth rate'];
        const max = cell['food full'];
        const food = cell['food'];
        if (food < max) {
          cell['food'] = Math.min(max, food + growthRate);
        }

        const foodAnimals = cell['food animals'];
        if (foodAnimals < max) {
          cell['food animals'] = Math.min(max, foodAnimals + growthRate);
        }
      })
    })
  }

  _wrapSingleDimension(p, max) {
    if (p < 0) {
      p = max + p;
    } else if (p >= max) {
      p = p - max;
    }
    return p;
  }

  _bounceSingleDimension(p, max) {
    if (p < 0) {
      p = p * -1;
    } else if (p >= max) {
      p = max - (p - max) - 1;
    }
    return p;
  }

  _remapSeasonLengths() {
    // re-map seasonLenths into end-dates for efficient access later
    let length;
    this._totalSeasonLengths = [];
    for (let i = 0; i < this.seasonLengths.length; i++) { length = this.seasonLengths[i]; this._totalSeasonLengths[i] = length + (this._totalSeasonLengths[i-1] || 0); }

    this.usingSeasons = this._totalSeasonLengths.length > 0;

    this.yearLength = this._totalSeasonLengths[3] || 0;
  }

  _setCellDefaults() {
    this.cells.forEach( col => {
      for (let row = 0; row < this.rows; row++) {
        col[row] = helpers.clone(cellDefaults);
      }
    });
  }
}

Environment.DEFAULT_RUN_LOOP_DELAY = 54.5;

Environment.EVENTS = {
  START:  "environment-start",
  STOP:   "environment-stop",
  STEP:   "environment-step",
  RESET:  "environment-reset",
  AGENT_ADDED: "agent-added",
  AGENT_EATEN: "agent-eaten",
  SEASON_CHANGED: "season-changed",
  USER_REMOVED_AGENTS: 'user-removed-agents'
};

class Barrier {
  constructor(x1, y1, width, height) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = this.x1 + width;
    this.y2 = this.y1 + height;
    this.corners = [];
    this.corners.push({x: this.x1, y: this.y1});
    this.corners.push({x: this.x1, y: this.y2});
    this.corners.push({x: this.x2, y: this.y1});
    this.corners.push({x: this.x2, y: this.y2});
  }

  contains(x, y) {
    return (this.x2 >= x && x >= this.x1) && (this.y2 >= y && y >= this.y1);
  }

  // check if we intersect. see: http://stackoverflow.com/questions/3590308/testing-if-a-line-has-a-point-within-a-triangle
  // tl;dr - by plugging in the corner points of the rectangle into the equation that describes the line from start to finish,
  // we can determine if all of the points lie on the same side of the line. If so, the path doesn't cross the barrier.
  // lineFunc should accept two params, x and y and return a number where negative indicates one side of the line,
  // positive indicates the other, with 0 indicating the point lies on the line. function(x,y) {...}
  intersectsLine(lineFunc){
    let previousSign = null;
    for (let corner of this.corners) {
      const number = lineFunc(corner.x, corner.y);
      if (number === 0) { return true; }
      const sign = number < 0 ? -1 : 1;
      if ((previousSign == null)) {
        previousSign = sign;
      } else if (sign !== previousSign) {
        return true;
      }
    }
    return false;
  }
}

/*
      *** User Interaction States ***
*/

var EmptyState = {
  enter() {
    this._view.setCursor("default-cursor");
  }
};

var AddAgentsState = {
  enter() {
    this._view.setCursor("add-agents");
  },
  click(evt) {
    this.addDefaultAgent(evt.envX, evt.envY);
  }
};


//# more states added by ui/tool-button
