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
    @barriers = []

    @agents = []

    @_view = new EnvironmentView({environment: @})

  ### Public API ###

  addAgent: (agent)->
    loc = agent.getLocation()
    if @isInBarrier loc.x, loc.y
      return false

    @agents.push(agent) unless @agents.indexOf(agent) != -1

  ensureValidLocation: ({x,y}) ->
    x = if @wrapEastWest   then @_wrapSingleDimension(x,  @width) else @_bounceSingleDimension(x,  @width)
    y = if @wrapNorthSouth then @_wrapSingleDimension(y, @height) else @_bounceSingleDimension(y, @height)

    return {x,y}

  setCellProperty: (x, y, prop, val) ->
    if not @cells[x][y]
      @cells[x][y] = {}

    @cells[x][y][prop] = val

  getCellProperty: (x, y, prop) ->
    if not @cells[x][y]
      return null

    return @cells[x][y][prop]

  addBarrier: (x, y, width, height) ->
    @barriers.push new Barrier x, y, width, height

  isInBarrier: (x, y) ->
    for barrier in @barriers
      if barrier.contains x, y
        return true
    return false

  start: ->
    runloop = ->
      setTimeout ->
        env.step()

  start: ->
    @_isRunning = true
    runloop = =>
      setTimeout =>
        @step()
        runloop() if @_isRunning
      , 200

    runloop()

  stop: ->
    @_isRunning = false

  step: ->
    # Apply all of the rules
    for r in @_rules
      for a in @agents
        r.execute(a)

  ### Default properties ###

  _columnWidth: 10
  _rowHeight:   10
  _rules: null

  _isRunning: false

  ### Getters and Setters ###

  getView: ->
    return @_view

  addRule: (rule)->
    @_rules ||= []
    @_rules.push(rule) unless @_rules.indexOf(rule) != -1

  removeRule: (rule)->
    @_rules ||= []
    @_rules.removeObj rule

  clearRules: ->
    @_rules = []

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

class Barrier
  constructor: (@x1, @y1, width, height) ->
    @x2 = @x1 + width
    @y2 = @y1 + height

  contains: (x, y) ->
    x > @x1 and x <= @x2 and y > @y1 and y <= @y2
