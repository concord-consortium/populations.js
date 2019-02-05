// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import Agent from '../agent';
import Environment from '../environment';
import Trait from '../trait';
import Events from '../../events';
import * as helpers from '../../helpers';

const defaultProperties = {
  'direction': 0,
  'speed': 1,
  'default speed': 10,
  'sex': 'female',
  'prey': [],
  'predator': [],
  'hiding place': [],
  'chance of being seen': 1.0,
  'max energy': 100,
  'energy': 100,
  'metabolism': 3,
  'vision distance': 300,
  'eating distance': 50,
  'mating distance': 50,
  'current behavior': 'wandering',
  'calculate drives': true,
  'hunger bonus': 0,
  'mating desire bonus': 0,
  'fear bonus': 0,
  'wandering threshold': 5,
  'bubble showing': 'none'
};

/*
  The base class of a simple animal
*/
export default class BasicAnimal extends Agent {

  constructor(args) {
    let defaults;
    if (args.additionalDefaults != null) {
      defaults = helpers.setDefaults(helpers.clone(defaultProperties), args.additionalDefaults);
    } else {
      defaults = helpers.clone(defaultProperties);
    }
    args.additionalDefaults = defaults;

    super(args);

    this.label = 'animal';
    this._viewLayer = 2;
    this._hasEatenOnce = false;
    this._timeLastMated = -20;
  }

  makeNewborn() {
    super.makeNewborn();
    this.set('sex', (helpers.ExtMath.flip() === 0 ? 'female' : 'male'));
    this.set('energy', this.get('max energy'));
    this.set('direction', helpers.ExtMath.randomFloat(2 * Math.PI));
    return this.set('speed', this.get('default speed'));
  }

  step() {
    this._closestAgents = null;
    this._setSpeedAppropriateForAge();
    this._depleteEnergy();
    if (this.get('calculate drives')) {
      this.set('current behavior', this._determineBehavior());
    }

    switch (this.get('current behavior')) {
      case BasicAnimal.BEHAVIOR.EATING:
        this.eat();
        break;
      case BasicAnimal.BEHAVIOR.FLEEING:
        this.flee();
        break;
      case BasicAnimal.BEHAVIOR.MATING:
        this.mate();
        break;
      case BasicAnimal.BEHAVIOR.WANDERING:
        this.wander();
        break;
      default:
    }
        // NOOP

    this._incrementAge();
    return this._checkSurvival();
  }

  eat() {
    const nearest = this._nearestPrey();
    if (nearest != null) {
      const eatingDist = this.get('eating distance');
      if (nearest.distanceSq < Math.pow(eatingDist, 2)) {
        return this._eatPrey(nearest.agent);
      } else {
        return this.chase(nearest);
      }
    } else {
      return this.wander(this.get('speed') * 0.75);
    }
  }

  flee() {
    const nearest = this._nearestPredator();
    if (nearest != null) {
      const hidingPlace = this._nearestHidingPlace();
      if (hidingPlace != null) {
        const speed = this.get('speed');
        this.set('speed', speed*6);
        this.chase(hidingPlace);
        this.set('speed', speed);

        if (hidingPlace.distanceSq < Math.pow(this.get('speed'), 2)) { return this.set('current behavior', BasicAnimal.BEHAVIOR.HIDING); }
      } else {
        return this.runFrom(nearest);
      }
    } else {
      return this.wander();
    }
  }

  mate() {
    const nearest = this._nearestMate();
    if (nearest != null) {
      this.chase(nearest);
      if ((nearest.distanceSq < Math.pow(this.get('mating distance'), 2)) && ((this.species.defs.CHANCE_OF_MATING == null) || (Math.random() < this.species.defs.CHANCE_OF_MATING))) {
        const max = this.get('max offspring');
        this.set('max offspring', Math.max(max/2, 1));
        this.reproduce(nearest.agent);
        this.set('max offspring', max);
        return this._timeLastMated = this.environment.date;
      }
    } else {
      return this.wander(this.get('speed') * Math.random() * 0.75);
    }
  }

  wander(speed){
    if (speed == null) {
      const maxSpeed = this.get('speed');
      speed = (maxSpeed/2) + (helpers.ExtMath.randomGaussian() * (maxSpeed/6));
    }
    this.set('direction', (this.get('direction') + (helpers.ExtMath.randomGaussian()/10)));
    return this.move(speed);
  }

  chase(agentDistance){
    const directionToAgent =  this._direction(this.getLocation(), agentDistance.agent.getLocation());
    const directionRelativeToMe = helpers.ExtMath.normalizeRads(directionToAgent - this.get('direction'));
    const directionToMove = this.get('direction') + (directionRelativeToMe / 10);
    this.set('direction', directionToMove);
    const speed = Math.min(this.get('speed'), Math.sqrt(agentDistance.distanceSq));
    return this.move(speed);
  }

  runFrom(agentDistance){
    const directionToRunTo =  this._direction(this.getLocation(), agentDistance.agent.getLocation()) + Math.PI + (helpers.ExtMath.randomGaussian()/3);
    const directionToMove = ((this.get('direction')*19) + directionToRunTo) / 20;
    this.set('direction', directionToMove);
    return this.move(this.get('speed'));
  }

  move(speed) {
    const dir = this.get('direction');
    if (speed == null) { speed = this.get('speed'); }
    if (speed === 0) { return; }
    if (typeof(speed) !== 'number') { throw new Error('invalid speed'); }
    if (typeof(dir) !== 'number') { throw new Error('invalid direction'); }
    const loc = this.getLocation();
    const dx = speed * Math.cos(dir);
    const dy = speed * Math.sin(dir);

    const newLoc = {x: loc.x + dx, y: loc.y + dy};
    if (this.environment.crossesBarrier(loc, newLoc)) {
      // stay where you are and turn around, for now
      return this.set('direction', dir + Math.PI);
    } else {
      return this.setLocation(newLoc);
    }
  }

  _direction(from, to){
    const dx = to.x - from.x;
    const dy = to.y - from.y;

    return helpers.ExtMath.normalizeRads(Math.atan2(dy, dx));
  }

  _eatPrey(agent){
    const food = agent.get('food');
    const currEnergy = this.get('energy');
    this.set('energy', Math.min(this.get('max energy'), currEnergy + food));
    agent.die();
    this._hasEatenOnce = true;

    return Events.dispatchEvent(Environment.EVENTS.AGENT_EATEN, {predator: this, prey: agent});
  }

  _setSpeedAppropriateForAge() {
    const age = this.get('age');
    let speed = this.get('default speed');
    if (age < 5) {
      speed = 2;
    } else if (age < 10) {
      speed = 5;
    }
    return this.set('speed', speed);
  }

  _depleteEnergy() {
    const currEnergy = this.get('energy');
    let rate = this.get('metabolism');
    const behavior = this.get('current behavior');
    if (behavior === BasicAnimal.BEHAVIOR.HIDING) {
      rate = rate/2;
    }
    return this.set('energy', Math.max(0, currEnergy - rate));
  }

  _hunger() {
    // hunger is just directly inversely proportional to energy
    const percentEnergy = this.get('energy') / this.get('max energy');

    // when we add the bonus, instead of the hunger line going from 0 to 100 it goes from 'bonus' to 100
    const range = 100 - this.get('hunger bonus');

    return 100 - (range * percentEnergy);
  }

  _fear() {
    if (!this.get('predator') instanceof String) {
      const nearest = this._nearestPredator();
      if (nearest != null) {
        const vision = this.get('vision distance');
        const percentCloseness = (vision - Math.sqrt(nearest.distanceSq)) / vision;
        return Math.pow(10 * percentCloseness, 2);
      }
    }

    return 0;
  }

  _desireToMate() {
    const age = this.get('age');
    if ((this.species.defs.MATURITY_AGE != null) && (age < this.species.defs.MATURITY_AGE)) { return 0; }
    if (this.get('max offspring') < 1) { return 0; }
    if (!this._hasEatenOnce) { return 0; }
    if ((this.environment.date - this._timeLastMated) < 20) { return 0; }

    const proximityDesire = (this._nearestMate() != null) ? 30 : 15;
    const reciprocationFactor = (this._nearestMatingMate() != null) ? 15 : 0;
    const matingBonus = this.get('mating desire bonus');

    return proximityDesire + reciprocationFactor + matingBonus;
  }

  _determineBehavior() {
    const hunger = this._hunger();
    const fear = this._fear();
    const desire = this._desireToMate();
    const wanderThreshold = this.get('wandering threshold');
    if ((hunger < wanderThreshold) && (fear < wanderThreshold) && (desire < wanderThreshold)) {
      return BasicAnimal.BEHAVIOR.WANDERING;
    }

    const max = Math.max(Math.max(hunger, fear), desire);
    // in case of ties, order is FLEE, EAT, MATE
    if (max === fear) {
      return BasicAnimal.BEHAVIOR.FLEEING;
    } else if (max === hunger) {
      return BasicAnimal.BEHAVIOR.EATING;
    } else {
      return BasicAnimal.BEHAVIOR.MATING;
    }
  }

  _nearestPredator() {
    const predator = this.get('predator');
    if ((predator != null) && (predator.length != null) && (predator.length > 0)) {
      const nearest = this._nearestAgentsMatching({types: predator, quantity: 1});
      return nearest[0] || null;
    }
    return null;
  }

  _nearestPrey() {
    const prey = this.get('prey');
    if ((prey != null) && (prey.length != null) && (prey.length > 0)) {
      const nearest = this._nearestAgentsMatching({types: prey});
      return nearest[helpers.ExtMath.randomInt(nearest.length)];
    }

    return null;
  }

  _nearestHidingPlace() {
    const hidingPlace = this.get('hiding place');
    if ((hidingPlace != null) && (hidingPlace.length != null) && (hidingPlace.length > 0)) {
      const nearest = this._nearestAgentsMatching({types: hidingPlace, quantity: 1});
      return nearest[0] || null;
    }

    return null;
  }

  _nearestMate() {
    const desiredSex = this.get('sex') === 'male' ? 'female' : 'male';
    const trait = new Trait({name: 'sex', possibleValues: [desiredSex]});
    const nearest = this._nearestAgentsMatching({types: [{name: this.species.speciesName, traits: [trait]}], quantity: 1, mating: true});
    return nearest[0] || null;
  }

  _nearestMatingMate() {
    const desiredSex = this.get('sex') === 'male' ? 'female' : 'male';
    const trait  = new Trait({name: 'sex', possibleValues: [desiredSex]});
    const trait2 = new Trait({name: 'current behavior', possibleValues: [BasicAnimal.BEHAVIOR.MATING]});
    const nearest = this._nearestAgentsMatching({types: [{name: this.species.speciesName, traits: [trait, trait2]}], quantity: 1, mating: true});
    return nearest[0] || null;
  }

  _nearestAgents() {
    if (this._closestAgents != null) { return this._closestAgents; }
    const loc = this.getLocation();
    let vision = this.get('vision distance');
    if (vision == null) { vision = this.get('speed') * 15; }
    const visibleArea = {x: loc.x - vision, y: loc.y - vision, width: vision*2, height: vision*2};
    const visibleAgents = this.environment.agentsWithin(visibleArea);

    const closest = [];
    for (let a of Array.from(visibleAgents)) {
      closest.push(new AgentDistance(a, this._distanceSquared(loc, a.getLocation())));
    }

    this._closestAgents = closest.sort((a,b)=> a.distanceSq - b.distanceSq);
    return this._closestAgents;
  }

  _nearestAgentsMatching(options){
    const opts = helpers.setDefaults(options, {
      camo: true,
      mating: false,
      quantity: 3,
      crossBarriers: false
    }
    );

    if ((opts.types == null) && (typeof(opts.types) === 'object') && !(opts.types.length == null)) { throw new Error("Must pass agent types array"); }

    const nearest = this._nearestAgents();
    const returnedAgents = [];
    for (let agentDistance of Array.from(nearest)) {
      const { agent } = agentDistance;
      for (let type of Array.from(opts.types)) {
        if ((typeof(type) !== 'object') || (type.name == null)) { throw new Error("types array must be an array of objects in format {name: 'foo', traits: []}"); }
        if (type.name !== agent.species.speciesName) { continue; }

        if (agent === this) { continue; }
        if (opts.camo && !opts.mating && agent instanceof BasicAnimal && (helpers.ExtMath.randomFloat() > agent.get('chance of being seen'))) { continue; }
        if (agent.hasProp('current behavior') && (agent.get('current behavior') === BasicAnimal.BEHAVIOR.HIDING)) { continue; }
        if (!opts.crossBarriers && this.environment.crossesBarrier(this.getLocation(), agent.getLocation())) { continue; }
        if ((type.traits != null) && (type.traits.length > 0)) {
          // All traits must match to be considered a valid agent match
          let nextType = false;
          for (let trait of Array.from(type.traits)) {
            if (!trait.isPossibleValue(agent.get(trait.name))) { nextType = true; }
          }
          if (nextType) { continue; }
        }

        returnedAgents.push(agentDistance);
        if (returnedAgents.length >= opts.quantity) { return returnedAgents; }
      }
    }

    return returnedAgents;
  }

  _distanceSquared(p1, p2){
    const dx = p1.x - p2.x;
    const dy = p1.y - p2.y;
    return ((dx*dx) + (dy*dy));
  }

  _getSurvivalChances() {
    if (this.get('is immortal')) { return 1.0; }

    const basicPct = super._getSurvivalChances();

    const energy = this.get('energy');
    const energyPct = 1 - Math.pow(1-(energy/100), 8);

    return basicPct * energyPct;
  }
}

BasicAnimal.BEHAVIOR = {
  EATING: 'eating',
  MATING: 'mating',
  FLEEING: 'fleeing',
  HIDING: 'hiding',
  WANDERING: 'wandering'
};

class AgentDistance {
  constructor(agent, distanceSq){
    this.agent = agent;
    this.distanceSq = distanceSq;
    undefined;
  }
}

