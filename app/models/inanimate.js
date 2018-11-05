/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Inanimate;
const Agent = require('models/agent');

/*
  The base class of an inanimate object
*/
module.exports = (Inanimate = (function() {
  Inanimate = class Inanimate extends Agent {
    static initClass() {
      this.prototype.label = "inanimate";
      this.prototype._viewLayer = 0;
  
      this.prototype._consumeResources = null;
    }
    step() {
      return undefined;
    }
  };
  Inanimate.initClass();
  return Inanimate;
})());
