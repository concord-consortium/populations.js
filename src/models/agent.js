// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import '../../bower_components/biologica.js/index';
import AgentView from '../views/agent-view';
import * as helpers from '../helpers';

const defaultProperties = {
  'min offspring': 1,
  'max offspring': 3,
  'min offspring distance': 10,
  'max offspring distance': 40,
  'health': 1,
  'is immortal': false,
  'resource deficit': 0,
  'resource consumption rate': 1
};

/*
  The base agent class
*/
export default class Agent {
  constructor({name, environment, species, x, y, additionalDefaults}) {

    this.label = "organism";
    this.bred = false;
    this._viewLayer = 1;

    this.isDead = false;

    this.name = name;
    this.environment = environment;
    this.species = species;
    this._props = helpers.clone(defaultProperties);
    if (additionalDefaults != null) { this._props = helpers.setDefaults(this._props, additionalDefaults); }
    this._view = new AgentView({agent: this});
    if ((this.species != null ? this.species.viewLayer : undefined) != null) { this._viewLayer = this.species.viewLayer; }
    if ((x != null) && (y != null)) {
      this.setLocation({x,y});
    }
    this.alleles = {};
    this.makeNewborn();
  }

  getView() {
    return this._view;
  }

  setLocation({x, y}) {
    // TODO When we support movement, we'll have to check if the results changed,
    // and if so, update the agent's movement direction
    if (this.environment) {
      ({x,y} = this.environment.ensureValidLocation({x,y}));
    }
    this._x = x;
    return this._y = y;
  }

  getLocation() {
    return {x: this._x, y: this._y};
  }

  set(prop, value) {
    return this._props[prop] = value;
  }

  get(prop) {
    let val;
    if (this.hasProp(prop)) { val = this._props[prop];
    } else { val = this.getEnvironmentProperty(prop); }

    if ((val == null)) { throw new Error(`Cannot find property ${prop}`); }
    return val;
  }

  hasProp(prop) {
    return (this._props[prop] != null);
  }

  getAllProperties() {
    return this._props;
  }

  getEnvironmentProperty(prop) {
    if (this.environment == null) { return null; }
    return this.environment.getAt(this._x, this._y, prop);
  }

  setEnvironmentProperty(prop, val) {
    if (this.environment == null) { return; }
    return this.environment.setAt(this._x, this._y, prop, val);
  }

  getImages(opts){
    if (opts == null) { opts = {}; }
    return this.species.getImages(this, opts);
  }

  getSize() {
    if (this.species.defs.MATURITY_AGE) {
      const maturity = this.get('age') / this.species.defs.MATURITY_AGE;
      return Math.min(maturity, 1);
    } else {
      return 1;
    }
  }

  die() {
    return this.isDead = true;
  }

  step() {
    this._incrementAge();
    return this._checkSurvival();
  }

  makeNewborn() {
    return this.set('age', 0);
  }

  /*
    Creates one or more offspring, depending on the min- and max- offspring
    properties, and places them in the environment.

    Returns the array of offspring.

    Only asexual for now
  */
  reproduce(mate) {
    const minOffspring = this.get('min offspring');
    const maxOffspring = this.get('max offspring');
    const numOffspring = minOffspring + helpers.ExtMath.randomInt((1 + maxOffspring) - minOffspring);

    return __range__(0, numOffspring, false).map((i) =>
      this.createOffspring(mate));
  }

  /*
    Returns an offspring and places it in the environment
  */
  createOffspring(mate) {
    const offspring = this._breed(mate);
    offspring._mutate(offspring.organism != null);
    offspring.makeNewborn();
    offspring.resetGeneticTraits((offspring.organism == null));
    offspring.bred = true;

    if (this.environment) {
      offspring.setLocation(this._findOffspringLocation());
      this.environment.addAgent(offspring);
    }

    return offspring;
  }

  resetGeneticTraits(createOrganism){
    if (createOrganism == null) { createOrganism = true; }
    if (this.species.geneticSpecies != null) {
      let trait;
      if (createOrganism) {
        const desired_sex = (this.hasProp('sex') && (this.get('sex') === 'male') ? window.BioLogica.MALE : window.BioLogica.FEMALE);
        const allele_set = [];
        for (trait of Object.keys(this.alleles || {})) { const allele = this.alleles[trait]; allele_set.push(allele); }
        this.organism = new window.BioLogica.Organism(this.species.geneticSpecies, allele_set.join(), desired_sex);
      }
      return (() => {
        const result = [];
        for (trait of Array.from(this.species.traits)) {
          if (trait.isGenetic) {
            const characteristic = this.organism.getCharacteristic(trait.name);
            if (trait.isNumeric) {
              result.push(this.set(trait.name, (trait.float ? parseFloat(characteristic) : parseInt(characteristic))));
            } else {
              result.push(this.set(trait.name, characteristic));
            }
          } else {
            result.push(undefined);
          }
        }
        return result;
      })();
    }
  }

  canShowInfo() {
    return true;
  }

  zIndex(val){
    if (val != null) {
      this._zIndex = val;
      return;
    }

    if (this._zIndex != null) { return this._zIndex; } else { return this._y; }
  }

  _clone() {
    const clone = this.species.createAgent();
    for (let prop in this._props) {
      clone.set(prop, this._props[prop]);
    }
    for (let trait in this.alleles) {
      const allele = this.alleles[trait];
      clone.alleles[trait] = allele;
    }
    return clone;
  }

  _breed(mate){
    const child = this._clone();
    if ((this.species.geneticSpecies != null) && (this.organism != null) && ((mate != null ? mate.organism : undefined) != null)) {
      let father, mother;
      if (this.hasProp('sex') && (this.get('sex') === 'male')) {
        mother = mate.organism;
        father = this.organism;
      } else {
        mother = this.organism;
        father = mate.organism;
      }
      child.organism = window.BioLogica.breed(mother, father, false); // TODO Support crossing over?
      if (child.hasProp('sex')) {
        child.set('sex', child.organism.sex === window.BioLogica.FEMALE ? 'female' : 'male');
      }
      for (let trait of Array.from(this.species.traits)) {
        if (trait.isGenetic) {
          // find the alleles and set them on the organism
          const alleleStr = child.organism.getAlleleStringForTrait(trait.name);
          child.alleles[trait.name] = alleleStr;
        }
      }
    }
    return child;
  }

  _mutate(skipGenetic){
    if (skipGenetic == null) { skipGenetic = false; }
    return (() => {
      const result = [];
      for (let trait of Array.from(this.species.traits)) {
        if (trait.mutatable && (Math.random() < this.species.defs.CHANCE_OF_MUTATION)) {
          var currentVal, mutatedVal;
          if (trait.isGenetic) {
            if (skipGenetic) { continue; }
            currentVal = this.alleles[trait.name];
            mutatedVal = trait.mutate(currentVal);
            result.push(this.alleles[trait.name] = mutatedVal);
          } else {
            currentVal = this.get(trait.name);
            mutatedVal = trait.mutate(currentVal);
            result.push(this.set(trait.name, mutatedVal));
          }
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  }

  _findOffspringLocation() {
    const loc = this.getLocation();

    const minD = this.get('min offspring distance');
    const maxD = this.get('max offspring distance');

    const distance = helpers.ExtMath.randomValue(minD, maxD);
    const angle    = Math.random() * 2 * Math.PI;

    const xStep = Math.floor(distance * Math.sin(angle));
    const yStep = Math.floor(distance * Math.cos(angle));

    return {x: loc.x + xStep, y: loc.y + yStep};
  }


  _incrementAge() {
    return this.set('age', this.get('age')+1);
  }

  _consumeResources() {
    const food = this.getEnvironmentProperty('food');
    const consumption = this.get('resource consumption rate');
    if (food >= consumption) {
      this.setEnvironmentProperty('food', food - consumption);
      return this.set('resource deficit', 0);
    } else {
      const underfed = consumption - food;
      const currDeficit = this.get('resource deficit');
      this.set('resource deficit', currDeficit + underfed);
      return this.setEnvironmentProperty('food', 0);
    }
  }

  _checkSurvival() {
    const chance = this.hasProp('chance of survival') ? this.get('chance of survival') : this._getSurvivalChances();
    if (Math.random() > chance) { return this.die(); }
  }

  _getSurvivalChances() {
    if (this.get('is immortal')) { return 1.0; }

    const age = this.get('age');
    const ageMax = this.species.defs.MAX_AGE || 2000;

    const agePct = 1 - (age/ageMax);

    // TODO factor in HUNGER
    const hunger = this.get('resource deficit');
    const hungerPct = 1 - Math.pow(hunger/100, 2);

    const healthPct = this.get('health')/this.species.defs.MAX_HEALTH;

    return agePct * hungerPct * healthPct;
  }
}


function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}