AgentView = require 'views/agent-view'
###
  The base agent class
###
module.exports = class Agent

  constructor: ({@name, @environment, @species, x, y}) ->
    @_props = {}
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

  set: (prop, value) ->
    @_props[prop] = value

  get: (prop) ->
    if @_props[prop]? then return @_props[prop]
    else return @getEnvironmentProperty prop

  getAllProperties: ->
    return @_props

  getEnvironmentProperty: (prop) ->
    @environment.getCellPropertyAt @_x, @_y, prop

  getImagePath: ->
    @species.getImage this