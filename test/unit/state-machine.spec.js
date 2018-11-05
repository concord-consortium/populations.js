/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const StateMachine = require('state-machine');

describe('A state machine', function() {

  let states = null;
  beforeEach(() => states = new StateMachine());

  it('can transition to an existing state', function() {
    states.addState("state1", {});

    states.setState("state1");

    return expect(states.currentState).toBe("state1");
  });

  it('throws an error when transitioning to an non-existing state', function() {
    states.addState("state1", {});

    return expect(() => states.setState("non-existing-state")).toThrow(new Error("No such state: non-existing-state"));
  });

  it('will fail to transition to an non-existing state', function() {
    states.addState("state1", {});

    states.setState("state1");

    expect(states.currentState).toBe("state1");

    expect(() => states.setState("non-existing-state")).toThrow(new Error("No such state: non-existing-state"));

    return expect(states.currentState).toBe("state1");
  });


  it('calls enter() on a state when it transitions to it', function() {
    const enterSpy = jasmine.createSpy("enter");
    states.addState("state1",
      {enter: enterSpy});

    states.setState("state1");

    return expect(enterSpy).toHaveBeenCalled();
  });

  it('throws an error when no current state is set and we try to send an event', function() {
    states.addState("state1", {
      click() {
        return undefined;
      }
    }
    );

    return expect( () => states.send("click")).toThrow(new Error("No current state exists to handle 'click'"));
  });

  it('sends an event to a state with arguments', function() {
    const clickAction = jasmine.createSpy("click");

    states.addState("state1",
      {click: clickAction});

    states.setState("state1");
    states.send("click", "xyz");

    return expect(clickAction).toHaveBeenCalledWith("xyz");
  });

  it('sends an event on the appropriate state', function() {
    const click1 = jasmine.createSpy("click1");
    const click2 = jasmine.createSpy("click2");

    states.addState("state1",
      {click: click1});
    states.addState("state2",
      {click: click2});

    states.setState("state1");
    states.send("click");

    expect(click1).toHaveBeenCalled();
    expect(click2).not.toHaveBeenCalled();

    states.setState("state2");
    states.send("click");

    expect(click2).toHaveBeenCalled();
    return expect(click1.calls.count()).toEqual(1);
  });

  return it('sends an event with the appropriate context', function() {
    const TellState = {
      tellMeAboutX() {
        return `The value of @x is ${this.x}`;
      }
    };

    states.x = "X";
    states.addState("tellState", TellState);
    states.setState("tellState");

    return expect(states.send("tellMeAboutX")).toBe("The value of @x is X");
  });
});


