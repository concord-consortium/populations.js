// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

export default class AnimatedAgent {

  constructor() {
    this.prototype.currentMovement = AnimatedAgent.MOVEMENTS.STOPPED;
  }

  setMovement(currentMovement) {
    this.currentMovement = currentMovement;
  }

  getMovement() {
    return this.currentMovement;
  }
}

AnimatedAgent.MOVEMENTS = {
  STOPPED: "stop",
  MOVESTEP: "move-step"
}
