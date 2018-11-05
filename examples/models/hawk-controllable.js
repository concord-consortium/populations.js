/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS202: Simplify dynamic range loops
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const helpers     = require('helpers');

const Environment = require('models/environment');
const Species     = require('models/species');
const Agent       = require('models/agent');
const Rule        = require('models/rule');
const Trait       = require('models/trait');
const Interactive = require('ui/interactive');
const Events      = require('events');
const ToolButton  = require('ui/tool-button');
const BasicAnimal = require('models/agents/basic-animal');

const plantSpecies  = require('species/fast-plants-roots');
const rabbitSpecies = require('species/white-brown-rabbits');
const hawkSpecies   = require('species/hawks');
const plusOne       = require('species/plus-one');
const env           = require('environments/snow');

window.model = {
  hawk: null,
  startingPlants: 200,
  startingRabbits: 25,
  setupEnvironment() {
    let i;
    let asc, end;
    for (i = 1, end = this.startingPlants, asc = 1 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
      const plant = plantSpecies.createAgent();
      plant.setLocation(this.env.randomLocation());
      this.env.addAgent(plant);
    }

    for (let color of ['white', 'brown']) {
      var asc1, end1;
      for (i = 1, end1 = this.startingRabbits, asc1 = 1 <= end1; asc1 ? i <= end1 : i >= end1; asc1 ? i++ : i--) {
        const rabbit = rabbitSpecies.createAgent();
        rabbit.set('age', 10);
        rabbit.set('mating desire bonus', 10);
        rabbit.set('hunger bonus', -10);
        rabbit.set('resource consumption rate', 10);
        rabbit.set('fear bonus', -1000);
        rabbit.set('color', color);
        rabbit.setLocation(this.env.randomLocation());
        this.env.addAgent(rabbit);
      }
    }

    this.hawk = hawkSpecies.createAgent();
    this.hawk.setLocation(this.env.randomLocation());
    this.hawk.set('is immortal', true);
    this.hawk.set('age', 20);
    this.hawk.set('speed', 0);
    this.hawk.set('default speed', 0);
    this.hawk.set('calculate drives', false);
    this.hawk.set('wings', 0);
    this.hawk.set('current behavior', BasicAnimal.BEHAVIOR.WANDERING);
    return this.env.addAgent(this.hawk);
  },

  run() {
    this.interactive = new Interactive({
      environment: env,
      speedSlider: false,
      addOrganismButtons: [],
      toolButtons: []});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.env = env;
    this.plantSpecies = plantSpecies;
    this.hawkSpecies = hawkSpecies;
    this.rabbitSpecies = rabbitSpecies;
    this.plusOne = plusOne;

    this.setupEnvironment();

    return Events.addEventListener(Environment.EVENTS.RESET, () => {
      return this.setupEnvironment();
    });
  },

  setupGraph() {
    const outputOptions = {
      title:  "Number of rabbits",
      xlabel: "Time (s)",
      ylabel: "Number of rabbits",
      xmax:   30,
      xmin:   0,
      ymax:   80,
      ymin:   0,
      xTickCount: 15,
      yTickCount: 8,
      xFormatter: "2d",
      yFormatter: "2d",
      realTime: false,
      fontScaleRelativeToParent: true,
      sampleInterval: (Environment.DEFAULT_RUN_LOOP_DELAY/1000),
      dataType: 'samples',
      dataColors: [
        "#999999",
        "#995500"
      ]
    };

    this.outputGraph = LabGrapher('#graph', outputOptions);

    // start the graph at 0,22
    this.outputGraph.addSamples([this.startingRabbits,this.startingRabbits]);

    Events.addEventListener(Environment.EVENTS.RESET, () => {
      this.outputGraph.reset();
      return this.outputGraph.addSamples([this.startingRabbits,this.startingRabbits]);
  });

    return Events.addEventListener(Environment.EVENTS.STEP, () => {
      let whiteRabbits = 0;
      let brownRabbits = 0;
      for (let a of Array.from(this.env.agents)) {
        if ((a.species === this.rabbitSpecies) && (a.get('color') === 'white')) { whiteRabbits++; }
        if ((a.species === this.rabbitSpecies) && (a.get('color') === 'brown')) { brownRabbits++; }
      }
      return this.outputGraph.addSamples([whiteRabbits, brownRabbits]);
  });
  },

  numEaten: 0,
  brownEaten: 0,
  whiteEaten: 0,
  setupControls() {
    this.env.addState('hawk-follow-mouse', {
      click: evt=> {
        this.hawk.setLocation({x: evt.envX, y: evt.envY});
        this.hawk.set('wings', 1);
        this._tryToEat();
        return setTimeout(() => {
          return this.hawk.set('wings', 0);
        }
        , 200);
      },

      mousemove: evt=> {
        return this.hawk.setLocation({x: evt.envX, y: evt.envY});
      }
    });
    this.env.setState('hawk-follow-mouse');

    const caughtElem = document.getElementById('caught-value');
    Events.addEventListener(Environment.EVENTS.RESET, () => {
      this.env.setState('hawk-follow-mouse');
      this.numEaten = 0;
      this.brownEaten = 0;
      this.whiteEaten = 0;
      return caughtElem.innerHTML = "0";
    });

    return Events.addEventListener(Environment.EVENTS.AGENT_EATEN, evt=> {
      if (evt.detail.predator === this.hawk) {
        this._createPlusOne();
        this.numEaten++;
        if (evt.detail.prey.get('color') === 'brown') { this.brownEaten++; }
        if (evt.detail.prey.get('color') === 'white') { this.whiteEaten++; }
        return caughtElem.innerHTML = `${this.numEaten}`;
      }
    });
  },

  _tryToEat() {
    const nearest = this.hawk._nearestPrey();
    if (nearest != null) {
      const eatingDist = this.hawk.get('eating distance');
      if (nearest.distanceSq < Math.pow(eatingDist, 2)) {
        const color = nearest.agent.get('color');
        if ((color === 'brown') || (ExtMath.flip() === 1)) {
          return this.hawk._eatPrey(nearest.agent);
        }
      }
    }
  },

  _createPlusOne() {
    const plus = this.plusOne.createAgent();
    plus.setLocation(this.hawk.getLocation());
    this.env.addAgent(plus);
    return setTimeout(() => plus.die()
    , 1000);
  },

  _numRabbits() {
    let count = 0;
    for (let a of Array.from(this.env.agents)) {
      if (a.species === this.rabbitSpecies) { count++; }
    }
    return count;
  },

  setupTimer() {
    return Events.addEventListener(Environment.EVENTS.STEP, () => {
      const t = Math.floor((this.env.date * Environment.DEFAULT_RUN_LOOP_DELAY) / 1000); // this will calculate seconds at default speed
      if ((t >= 30) || (this._numRabbits() === 0)) {
        this.env.stop();
        if (this.numEaten === 0) {
          return this.showMessage("Oh no, you didn't catch any rabbits!<br/>Press Reset to try again, and be sure to click on the rabbits to eat them.");
        } else {
          return this.showMessage(`Good job! You caught ${this.numEaten} rabbits!<br/>You caught ${this.whiteEaten} white rabbits and ${this.brownEaten} brown rabbits.`, () => {
            return this.showMessage("Take a picture of the graph. Then continue on.");
          });
        }
      }
    });
  },

  showMessage(message, callback) {
    return helpers.showMessage(message, this.env.getView().view.parentElement, callback);
  }
};

window.onload = () =>
  helpers.preload([env, plantSpecies, rabbitSpecies, hawkSpecies, plusOne], function() {
    model.run();
    model.setupGraph();
    model.setupControls();
    return model.setupTimer();
  })
;
