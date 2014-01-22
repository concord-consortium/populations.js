AgentView = require 'views/agent-view'
###
  The base agent class
###
module.exports = class Agent

  constructor: ({@name, @environment, @species, x, y}) ->
    @props = {}
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

  setProperty: (name, value) ->
    @props[name] = value

  getEnvironmentProperty: (prop) ->
    @environment.getCellPropertyAt @_x, @_y, prop

  getImagePath: ->
    @species.getImage this