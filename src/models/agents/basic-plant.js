// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import Agent from '../agent';
import * as helpers from '../../helpers';

const defaultProperties = {
  'is seed': true,
  'can seed': true,
  'has flowers': false,
  'chance of flowering': 1
};

/*
	The base class of a simple plant
*/
export default class BasicPlant extends Agent {

  constructor(args) {
    super(args);

    this.label = 'plant';
    this._hasSeeded = false;
    this._props = helpers.setDefaults(this._props, defaultProperties);
  }

  getSize() {
    const age = this.get('age');
    if (this.species.defs.SPROUT_AGE && (age < this.species.defs.SPROUT_AGE)) {
      return 1;
    } else if (this.species.defs.MATURITY_AGE) {
      const maturity = this.get('age') / this.species.defs.MATURITY_AGE;
      return Math.min(maturity, 1);
    } else {
      return 1;
    }
  }

  makeNewborn() {
    super.makeNewborn();
    return this.set('has flowers', false);
  }

  createSeeds() {
    // quick addition to prevent over-popualtion. This could also be controlled
    // by a species setting
    if (this.get('num agents') > 2) { return; }

    this.reproduce();
    this._hasSeeded = true;
    return this.set('has flowers', false);
  }

  step() {
    const age     = this.get('age');
    const season  = this.get('season');

    // seeds are frozen and do not start aging until spring
    if ((age === 0) && (season !== "spring")) {
      return;
    }

    this._incrementAge();

    if (this.get('is seed')) {
      if (age < this.species.defs.SPROUT_AGE) {
        return;
      } else {
        this.set('is seed', false);
      }
    }

    if ((!this._hasSeeded) && this.species.defs.CAN_SEED) {
      if (!this.get('has flowers') && (age > this.species.defs.MATURITY_AGE) && ((!this.species.defs.IS_ANNUAL) || (season !== "fall"))) {
        if (Math.random() < this.get('chance of flowering')) {
          this.set('has flowers', true);
        }
      }

      if (this.get('has flowers')) {
        if (this.species.defs.IS_ANNUAL) {
          if ((season === "fall") && (Math.random() < this.species.defs.CHANCE_OF_SEEDING)) {
            this.createSeeds();
          }
        } else {
          if (Math.random() < this.species.defs.CHANCE_OF_SEEDING) {
            this.createSeeds();
          }
        }
      }
    }

    if ((season === 'winter') && !this.get('is immortal')) {
      const health = this.get('health');
      this.set('health', health * 0.5);
    }

    return this._checkSurvival();
  }
}