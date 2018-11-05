// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/*
  This is a simple implementation of a state machine, which allows
  transitioning to named states and delegation of events to the
  current state.
*/

let StateMachine;
module.exports = (StateMachine = (function() {
  StateMachine = class StateMachine {
    static initClass() {
  
      this.prototype._states = null;
    }

    /*
      Add a named state with a set of event handlers.

      e.g.
        addState "addingAgents",
          enter: ->
            console.log "We are now in 'Adding Agents' mode!"
          click: (evt) ->
            addAgentAt evt.x, evt.y
          rightClick: (evt) ->
            removeAgent evt.x, evt.y
    */
    addState(name, state) {
      if ((this._states == null)) { this._states = []; }

      return this._states[name] = state;
    }

    setState(currentState) {
      if ((this._states[currentState] == null)) {
        throw new Error(`No such state: ${currentState}`);
      }

      this.currentState = currentState;
      if (this._states[this.currentState].enter != null) {
        return this._states[this.currentState].enter.apply(this);
      }
    }

    send(evtName, evt) {
      if ((this.currentState == null)) {
        throw new Error(`No current state exists to handle '${evtName}'`);
      }

      if (this._states[this.currentState][evtName] != null) {
        return this._states[this.currentState][evtName].apply(this, [evt]);
      // oddly, touch quit generating 'click' events, so here's a workaround for it
      } else if ((evtName === "touchstart") && (this._states[this.currentState]['click'] != null)) {
        evt.preventDefault();
        return this._states[this.currentState]['click'].apply(this, [evt]);
      }
    }
  };
  StateMachine.initClass();
  return StateMachine;
})());
