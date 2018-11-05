/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AnimatedAgent;
module.exports = (AnimatedAgent = (function() {
  AnimatedAgent = class AnimatedAgent {
    static initClass() {
  
      this.MOVEMENTS = {
        STOPPED: "stop",
        MOVESTEP: "move-step"
      };
  
      this.prototype.currentMovement = AnimatedAgent.MOVEMENTS.STOPPED;
    }

    setMovement(currentMovement) {
      this.currentMovement = currentMovement;
      return undefined;
    }

    getMovement() {
      return this.currentMovement;
    }
  };
  AnimatedAgent.initClass();
  return AnimatedAgent;
})());
