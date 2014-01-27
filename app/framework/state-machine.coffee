###
  This is a simple implementation of a state machine, which allows
  transitioning to named states and delegation of events to the
  current state.
###

module.exports = class StateMachine

  _states: null

  ###
    Add a named state with a set of event handlers.

    e.g.
      addState "addingAgents",
        enter: ->
          console.log "We are now in 'Adding Agents' mode!"
        click: (evt) ->
          addAgentAt evt.x, evt.y
        rightClick: (evt) ->
          removeAgent evt.x, evt.y
  ###
  addState: (name, state) ->
    if !@_states? then @_states = []

    @_states[name] = state

  setState: (currentState) ->
    if !@_states[currentState]?
      throw "No such state: #{currentState}"

    @currentState = currentState
    if @_states[@currentState].enter?
      @_states[@currentState].enter()

  send: (evtName, evt) ->
    if !@currentState?
      throw "No current state exists to handle '#{evtName}'"

    if @_states[@currentState][evtName]?
      @_states[@currentState][evtName].apply @, [evt]