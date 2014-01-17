###
  The base agent class
###
module.exports = class Agent

	constructor: ({@name, @environment, x, y}) ->
    if x && y
      @setLocation({x,y})

  setLocation: ({x, y}) ->
    # TODO When we support movement, we'll have to check if the results changed,
    # and if so, update the agent's movement direction
    {@x,@y} = @environment.ensureValidLocation({x,y})

  getLocation: ->
    {@x,@y}
