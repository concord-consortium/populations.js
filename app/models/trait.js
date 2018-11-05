// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/*
  A Trait is a property of a species, and all traits have a set of possible values.
  Each agent in a species has a specific value for each of these traits. This set
  is the agent's properties.

  For example, the species Plant might have the traits
    "health": 0-1
    "number of leaves": 0, 2, 4
    "leaf color": ["green", "red"]

  and an individual plant agent might have the properties
    "health": 0.9
    "number of leaves": 2
    "leaf color": "green"

  The Trait class defines the allowed values for each trait and has helper methods for
  picking random values and mutating a value.
*/

let Trait;
require('helpers');

module.exports = (Trait = class Trait {

  constructor({name, possibleValues, min, max, default1, float, mutatable, isGenetic, isNumeric}) {
    this.name = name;
    this.possibleValues = possibleValues;
    this.min = min;
    this.max = max;
    this.default = default1;
    this.float = float;
    this.mutatable = mutatable;
    this.isGenetic = isGenetic;
    this.isNumeric = isNumeric;
    undefined;
  }

  getDefaultValue() {
    if (this.default != null) { return this.default;
    } else { return this.getRandomValue(); }
  }

  getRandomValue() {
    if (this.possibleValues) {
      return this.possibleValues.randomElement();
    } else {
      if (this.float) {
        return ExtMath.randomValue(this.min, this.max);
      } else {
        return Math.floor(ExtMath.randomValue(this.min, this.max+1));
      }
    }
  }

  mutate(val) {
    if (!this.mutatable) { return val; }
    if (this.possibleValues && (this.possibleValues.length > 1)) {
      let newVal;
      while (true) {              // silly coffeescript do-while
        newVal = this.getRandomValue();
        if (newVal !== val) { break; }
      }
      return newVal;
    } else if (this.max) {
      return this._mutateValueFromRange(val);
    } else {
      return val;
    }
  }

  isPossibleValue(val){
    return this.possibleValues.indexOf(val) !== -1;
  }

  inherit(motherVal, fatherVal) {
    let inheritedVal = null;
    if (!this.isGenetic) {
      if (this.possibleValues != null) {
        // randomly pick either the mother's or the father's
        inheritedVal = (ExtMath.flip() === 0 ? motherVal : fatherVal);
      } else {
        if (this.float) {
          inheritedVal = ExtMath.randomValue(motherVal, fatherVal);
        } else {
          if (motherVal > fatherVal) {
            motherVal += 1;
          } else {
            fatherVal += 1;
          }
          inheritedVal = Math.floor(ExtMath.randomValue(motherVal, fatherVal));
        }
      }
    }
    return inheritedVal;
  }

  _mutateValueFromRange(val) {
    const sign = ExtMath.flip() ? 1 : -1;
    const diff  = this.float ? 0.1 : 1;
    val += (diff * sign);

    val = Math.max(val, this.min);
    val = Math.min(val, this.max);

    return val;
  }
});

