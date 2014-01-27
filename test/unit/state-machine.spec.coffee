StateMachine = require 'state-machine'

describe 'A state machine', ->

  states = null
  beforeEach ->
    states = new StateMachine()

  it 'can transition to an existing state', ->
    states.addState "state1", {}

    states.setState "state1"

    expect(states.currentState).toBe("state1")

  it 'throws an error when transitioning to an non-existing state', ->
    states.addState "state1", {}

    expect(->
      states.setState "non-existing-state"
    ).toThrow(new Error("No such state: non-existing-state"))

  it 'will fail to transition to an non-existing state', ->
    states.addState "state1", {}

    states.setState "state1"

    expect(states.currentState).toBe("state1")

    expect(->
      states.setState "non-existing-state"
    ).toThrow(new Error("No such state: non-existing-state"))

    expect(states.currentState).toBe("state1")


  it 'calls enter() on a state when it transitions to it', ->
    enterSpy = jasmine.createSpy("enter")
    states.addState "state1",
      enter: enterSpy

    states.setState "state1"

    expect(enterSpy).toHaveBeenCalled()

  it 'throws an error when no current state is set and we try to send an event', ->
    states.addState "state1",
      click: ->

    expect( ->
      states.send "click"
    ).toThrow(new Error("No current state exists to handle 'click'"))

  it 'sends an event to a state with arguments', ->
    clickAction = jasmine.createSpy("click")

    states.addState "state1",
      click: clickAction

    states.setState "state1"
    states.send "click", "xyz"

    expect(clickAction).toHaveBeenCalledWith("xyz");

  it 'sends an event on the appropriate state', ->
    click1 = jasmine.createSpy("click1")
    click2 = jasmine.createSpy("click2")

    states.addState "state1",
      click: click1
    states.addState "state2",
      click: click2

    states.setState "state1"
    states.send "click"

    expect(click1).toHaveBeenCalled()
    expect(click2).not.toHaveBeenCalled()

    states.setState "state2"
    states.send "click"

    expect(click2).toHaveBeenCalled()
    expect(click1.calls.length).toEqual(1)

  it 'sends an event with the appropriate context', ->
    TellState =
      tellMeAboutX: ->
        return "The value of @x is #{@x}"

    states.x = "X"
    states.addState "tellState", TellState
    states.setState "tellState"

    expect(states.send("tellMeAboutX")).toBe "The value of @x is X"


