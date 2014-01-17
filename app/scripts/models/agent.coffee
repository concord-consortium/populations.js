AgentView = require 'views/agent-view'
###
  The base agent class
###
module.exports = class Agent

  constructor: ({@name, @environment, x, y}) ->
    @imgPath = "images/agents/plant-healthy-75.png"
    @_view = new AgentView({agent: @})
    if x? && y?
      @setLocation({x,y})

  getView: ->
    return @_view

  setLocation: ({x, y}) ->
    # TODO When we support movement, we'll have to check if the results changed,
    # and if so, update the agent's movement direction
    if @environment
      {x,y} = @environment.ensureValidLocation({x,y})
    @_x = x
    @_y = y

  getLocation: ->
    {x: @_x, y: @_y}
