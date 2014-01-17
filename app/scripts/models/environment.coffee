EnvironmentView = require 'views/environment-view'

module.exports = class Environment

  constructor: ({@width, @height, @imgPath}) ->
    @view = new EnvironmentView({environment: @})
    @agents = []

  getView: ->
    return @view

  addAgent: (agent)->
    @agents.push(agent) unless @agents.indexOf(agent) != -1

  ensureValidLocation: ({x,y}) ->
    x = if @wrapEastWest   then @_wrapSingleDimension(x,  @width) else @_bounceSingleDimension(x,  @width)
    y = if @wrapNorthSouth then @_wrapSingleDimension(y, @height) else @_bounceSingleDimension(y, @height)
    return {x,y}

  _wrapSingleDimension: (p, max) ->
    if p < 0
      p = max + p
    else if p >= max
      p = p - max
    return p

  _bounceSingleDimension: (p, max) ->
    if p < 0
      p = p * -1
    else if p >= max
      p = max - (p - max) - 1
    return p
