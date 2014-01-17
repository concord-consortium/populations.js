EnvironmentView = require 'views/environment-view'

module.exports = class Environment
  wrapEastWest: false
  wrapNorthSouth: false

  constructor: ({@columns, @rows, @imgPath}) ->
    @width = @columns * @_columnWidth
    @height = @rows * @_rowHeight
    @_view = new EnvironmentView({environment: @})
    @agents = []

  ### Public API ###

  addAgent: (agent)->
    @agents.push(agent) unless @agents.indexOf(agent) != -1

  ensureValidLocation: ({x,y}) ->
    x = if @wrapEastWest   then @_wrapSingleDimension(x,  @width) else @_bounceSingleDimension(x,  @width)
    y = if @wrapNorthSouth then @_wrapSingleDimension(y, @height) else @_bounceSingleDimension(y, @height)
    return {x,y}

  ### Default properties ###

  _columnWidth: 10
  _rowHeight:   10

  ### Getters and Setters ###

  getView: ->
    return @_view

  setColumnWidth: (w) ->
    @_columnWidth = w
    @width = @columns * @_columnWidth

  setRowHeight: (h) ->
    @_rowHeight = h
    @height = @rows * @_rowHeight

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
