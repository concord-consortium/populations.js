// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Rule;
module.exports = (Rule = class Rule {

  // test: a function that returns true if the rule applies, and false otherwise, Will be passed an Agent
  //       if test is not defined, rule is always executed
  // action: a function that will be called if test returns true. Will be passed an Agent.
  constructor({test, action}) {
    if ((action == null) || (typeof(action) !== 'function')) { throw new Error("action is not a function!"); }
    this._test = test;
    this._action = action;
  }

  execute(agent){
    try {
      if ((this._test == null) || this._test(agent)) { return this._action(agent); }
    } catch (e) {
      return console.log(`Error executing rule!${e}`);
    }
  }
});
