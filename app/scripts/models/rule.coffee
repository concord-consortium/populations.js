module.exports = class Rule

  # test: a function that returns true if the rule applies, and false otherwise, Will be passed an Agent
  # action: a function that will be called if test returns true. Will be passed an Agent.
  constructor: ({test, action}) ->
    throw "test is not a function!"   unless   test? and typeof(  test) is 'function'
    throw "action is not a function!" unless action? and typeof(action) is 'function'
    @_test = test
    @_action = action

  execute: (agent)->
    try
      @_action(agent) if @_test(agent)
    catch e
      console.log("Error executing rule!" + e)
