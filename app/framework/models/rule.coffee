module.exports = class Rule

  # test: a function that returns true if the rule applies, and false otherwise, Will be passed an Agent
  #       if test is not defined, rule is always executed
  # action: a function that will be called if test returns true. Will be passed an Agent.
  constructor: ({test, action}) ->
    throw "action is not a function!" unless action? and typeof(action) is 'function'
    @_test = test
    @_action = action

  execute: (agent)->
    try
      @_action(agent) if !@_test? || @_test(agent)
    catch e
      console.log("Error executing rule!" + e)
