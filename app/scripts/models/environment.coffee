EnvironmentView = require 'views/environment-view'

module.exports = class Environment
  wrapEastWest: false
  wrapNorthSouth: false

  constructor: ({@columns, @rows, @height, @width, @imgPath}) ->
    if @columns and @width
      throw "You can set columns and rows, or width and height, but not both"
    if @columns
      @width = @columns * @_columnWidth
      @height = @rows * @_rowHeight
    if @width
      if not (@width % @_columnWidth == 0)
        throw "Width #{@width} is not evenly divisible by the column width #{@_columnWidth}"
      if not (@height % @_rowHeight == 0)
        throw "Height #{@height} is not evenly divisible by the row height #{@_rowHeight}"
      @columns = @width / @_columnWidth
      @rows = @height / @_rowHeight

    @cells = []
    @cells[col] = [] for col in [0..@columns]
    @agents = []

    @_view = new EnvironmentView({environment: @})

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
