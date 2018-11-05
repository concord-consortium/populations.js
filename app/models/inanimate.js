// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import Agent from './agent';

/*
  The base class of an inanimate object
*/
export default class Inanimate extends Agent {
  constructor(args) {
    super(args);
    this.label = "inanimate";
    this._viewLayer = 0;

    this._consumeResources = null;
  }
  step() {
    return;
  }
}
