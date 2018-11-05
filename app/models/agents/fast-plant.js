// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import Agent from '../agent';
import * as helpers from '../../helpers';

const defaultProperties = {
  'growth rate': 0.5,
  'min offspring': 1,
  'max offspring': 2,
  'max offspring distance': 150,
  'food quantity': 20
};

/*
  The base class of a simple plant
*/
export default class FastPlant extends Agent {

  constructor(args) {
    super(args);

    this.label = 'plant';
    this._hasSeeded = false;

    // FastPlant defaults take priority over Agent defaults
    this._props = helpers.setDefaults(helpers.clone(defaultProperties), this._props);
  }

  getSize() {
    return 1;
  }

  makeNewborn() {
    this.set('age', 10);
    this.set('chance of survival', 1.0);
    return this.set('resource deficit', 0);
  }

  step() {
    const food = this.getEnvironmentProperty('food');
    if (food > 0) {
      if (helpers.ExtMath.randomFloat(1) < this.get('growth rate')) {
        this.reproduce();
      }
    }

    return this._checkSurvival();
  }

  _checkSurvival() {
    const chance = this.get('chance of survival');
    if (helpers.ExtMath.randomFloat(1) > chance) {
      return this.die();
    }
  }
}
