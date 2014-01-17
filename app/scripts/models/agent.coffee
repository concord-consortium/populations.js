AgentView = require 'views/agent-view'
###
  The base agent class
###
module.exports = class Agent

	constructor: ({@name, @environment, x, y}) ->
    @imgPath = "images/agents/plant-healthy-75.png"
    @view = new AgentView({agent: @})
    if x && y
      @setLocation({x,y})

  getView: ->
    return @view

  setLocation: ({x, y}) ->
    # TODO When we support movement, we'll have to check if the results changed,
    # and if so, update the agent's movement direction
    {@x,@y} = @environment.ensureValidLocation({x,y})

  getLocation: ->
    {@x,@y}
