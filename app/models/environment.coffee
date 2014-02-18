EnvironmentView = require 'views/environment-view'
StateMachine = require 'state-machine'
helpers = require "helpers"
Events = require 'events'

SEASONS = ["spring", "summer", "fall", "winter"]

defaultOptions =
 #columns         :   # not defined because it may conflict with width
 #rows            :
 #width           :   # not defined because it may conflict with columns
 #height          :
  imgPath         : ""
  winterImgPath   : null
  barriers        : []
  wrapEastWest    : false
  wrapNorthSouth  : false
  seasonLengths   : []      # optionally the lengths of [spring, summer, fall, winter]

cellDefaults =
  'food'               : 100
  'food animals'       : 100
  'food full'          : 100
  'food low'           :  30
  'food regrowth rate' :   3

#Other options also accessible by @get
# season          :   # set by seasonsLength
# yearLength      :   # set by seasonsLength

module.exports = class Environment extends StateMachine

  constructor: (opts) ->
    opts = helpers.setDefaults(opts, defaultOptions)
    @[prop] = opts[prop] for prop of opts     # give us immediate access to @columns, @barriers, etc

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
    @_setCellDefaults()

    barriers = @barriers.slice()
    @barriers = []
    for barrier in (barriers || [])
      @addBarrier.apply this, barrier

    @agents = []
    @_rules = []

    @carriedAgent = null

    @_remapSeasonLengths()

    @season = SEASONS[0]
    @date   = 0

    # Add User Interaction states
    @addState @UI_STATE.NONE, EmptyState
    @addState @UI_STATE.ADD_AGENTS, AddAgentsState

    @_view = new EnvironmentView({environment: @})

    @setState @UI_STATE.NONE

  ### Public API ###

  addAgent: (agent)->
    agent.environment = this
    loc = @ensureValidLocation agent.getLocation()
    agent.setLocation loc
    if @isInBarrier loc.x, loc.y
      return false

    col = Math.floor loc.x / @_columnWidth
    row = Math.floor loc.y / @_rowHeight
    agents = @get col, row, "num agents"
    if !agents?
      @set col, row, "num agents", 1
    else
      @set col, row, "num agents", agents+1

    unless @agents.indexOf(agent) != -1
      @agents.push(agent)
      Events.dispatchEvent(Environment.EVENTS.AGENT_ADDED, {agent: agent})
      return true
    return false

  removeAgent: (agent)->
    loc = agent.getLocation()
    col = Math.floor loc.x / @_columnWidth
    row = Math.floor loc.y / @_rowHeight
    agents = @get col, row, "num agents"
    if !agents?
      @set col, row, "num agents", 0
    else
      @set col, row, "num agents", agents-1

    agent.getView().remove(@getView().stage) if @agents.removeObj(agent)

  ensureValidLocation: ({x,y}) ->
    x = if @wrapEastWest   then @_wrapSingleDimension(x,  @width) else @_bounceSingleDimension(x,  @width)
    y = if @wrapNorthSouth then @_wrapSingleDimension(y, @height) else @_bounceSingleDimension(y, @height)

    return {x,y}

  set: (col, row, prop, val) ->
    if not @cells[col][row]
      @cells[col][row] = {}

    @cells[col][row][prop] = val

  get: (col, row, prop) ->
    # get global properties first
    if @[prop]?
      return @[prop]
    if not @cells[col][row]
      return null

    return @cells[col][row][prop]

  getAt: (x, y, prop) ->
    col = Math.floor x / @_columnWidth
    row = Math.floor y / @_rowHeight
    return @get(col, row, prop)

  setAt: (x, y, prop, val) ->
    col = Math.floor x / @_columnWidth
    row = Math.floor y / @_rowHeight
    return @set(col, row, prop, val)

  getAgentAt: (x,y)->
    for agent in @agents
      if agent.getView().contains(x,y,@_view.stage)
        return agent
    return null

  addBarrier: (x, y, width, height) ->
    @barriers.push new Barrier x, y, width, height

  crossesBarrier: (start, finish)->
    dx = finish.x - start.x
    dy = finish.y - start.y
    if dx isnt 0
      m = dy/dx
      line = (x,y)->
        return m * (x - start.x) + start.y - y
    else
      line = (x,y)->
        return x - start.x
    for barrier in @barriers
      return true if barrier.contains(finish.x, finish.y)
      return false if (start.x > barrier.x2 and finish.x > barrier.x2) or # entirely to the right
                      (start.x < barrier.x1 and finish.x < barrier.x1)    # entirely to the left
                      (start.y > barrier.y2 and finish.y > barrier.y2)    # entirely below
                      (start.y < barrier.y1 and finish.y < barrier.y1)    # entirely above
      return true if barrier.intersectsLine(line)
    return false

  setSeasonLength: (season, length)->
    idx = -1
    switch season
      when "spring",0 then idx = 0
      when "summer",1 then idx = 1
      when "fall",2 then idx = 2
      when "winter",3 then idx = 3
      else throw "Invalid season '" + season + "'"

    @seasonLengths[idx] = length
    @_remapSeasonLengths()

  isInBarrier: (x, y) ->
    for barrier in @barriers
      if barrier.contains x, y
        return true
    return false

  pickUpAgent: (agent) ->
    @removeAgent(agent)
    @carriedAgent = agent

  dropCarriedAgent: ->
    unless @addAgent(@carriedAgent)
      # drop the agent back on it's original location if addAgent returns false
      @carriedAgent.setLocation @_agentOrigin
      @addAgent(@carriedAgent)
    @carriedAgent = null


  # Used for setting the default species and traits for
  # creating and adding agents.
  setDefaultAgentCreator: (@defaultSpecies, @defaultTraits, @agentAdderCallback) ->

  addDefaultAgent: (x, y) ->
    return unless @defaultSpecies?
    agent = @defaultSpecies.createAgent(@defaultTraits)
    agent.environment = @
    agent.setLocation x: x, y: y
    success = @addAgent agent
    if success and @agentAdderCallback then @agentAdderCallback()

  ### Run Loop ###

  # Speed is a value between 0 and 100, 0 being slow and 100 being fast.
  # The default is 50.
  setSpeed: (speed)->
    @_speed = speed
    # fps curve that looks like this:
    # http://fooplot.com/#W3sidHlwZSI6MCwiZXEiOiIoLTEvKCh4LTE0MSkvNDAwMCkpLTI3LjMiLCJjb2xvciI6IiMwMDAwMDAifSx7InR5cGUiOjEwMDAsIndpbmRvdyI6WyIwIiwiMTAwIiwiMCIsIjgwIl19XQ--
    fps = (-1/((speed-141)/4000))-27.3
    delay = 1000/fps
    @_runLoopDelay = delay

  start: ->
    @_isRunning = true
    runloop = =>
      setTimeout =>
        @step()
        runloop() if @_isRunning
      , @_runLoopDelay

    runloop()

  stop: ->
    @_isRunning = false

  step: ->
    @_incrementDate()
    # Apply all of the rules
    for r in @_rules
      for a in @agents
        r.execute(a)
    for a in @agents
      a._consumeResources() if a._consumeResources?
      a.step()
    @_replenishResources()
    i = 0
    while i < @agents.length
      a = @agents[i]
      if a.isDead
        @removeAgent(a)
      else
        i++
    Events.dispatchEvent(Environment.EVENTS.STEP, {})

  reset: ->
    i = @agents.length
    @removeAgent @agents[--i] while i
    Events.dispatchEvent(Environment.EVENTS.RESET, {})

  ### Default properties ###

  _columnWidth: 10
  _rowHeight:   10
  _rules: null
  _speed: 50
  _runLoopDelay: 54.5

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

  _incrementDate: ->
    @date++
    if @usingSeasons and @_totalSeasonLengths.length == 4
      yearDate = @date % @yearLength
      for length, i in @_totalSeasonLengths
        if yearDate < length
          if @season isnt SEASONS[i]
            @season = SEASONS[i]
            Events.dispatchEvent(Environment.EVENTS.SEASON_CHANGED, {season: @season})
          break

      if yearDate == @_totalSeasonLengths[2] # first day of winter
        @_view.addWinterImage()
      else if yearDate == @_totalSeasonLengths[3]-1 # last day of winter
        @_view.removeWinterImage()

  _replenishResources: ->
    for x in [0..@columns]
      for y in [0..@rows]
        cell = @cells[x][y]
        growthRate = cell['food regrowth rate']
        max = cell['food full']
        food = cell['food']
        if food < max
          cell['food'] = Math.min(max, food+growthRate)

        food = cell['food animals']
        if food < max
          cell['food animals'] = Math.min(max, food+growthRate)

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

  _remapSeasonLengths: ->
    # re-map seasonLenths into end-dates for efficient access later
    @_totalSeasonLengths = [];
    @_totalSeasonLengths[i] = length + (@_totalSeasonLengths[i-1] || 0) for length, i in @seasonLengths

    @usingSeasons = @_totalSeasonLengths.length > 0

    @yearLength = @_totalSeasonLengths[3] || 0

  _setCellDefaults: ->
    for x in [0..@columns]
      for y in [0..@rows]
        @cells[x][y] = helpers.clone cellDefaults

  ### Events ###
  @EVENTS:
    STEP:   "environment-step"
    RESET:  "environment-reset"
    AGENT_ADDED: "agent-added"
    SEASON_CHANGED: "season-changed"

  ### UI States ###

  UI_STATE:
    NONE: "None"
    ADD_AGENTS: "Add Agents"

class Barrier
  constructor: (@x1, @y1, width, height) ->
    @x2 = @x1 + width
    @y2 = @y1 + height
    @corners = []
    @corners.push {x: @x1, y: @y1}
    @corners.push {x: @x1, y: @y2}
    @corners.push {x: @x2, y: @y1}
    @corners.push {x: @x2, y: @y2}

  contains: (x, y) ->
    @x2 >= x >= @x1 and @y2 >= y >= @y1

  # check if we intersect. see: http://stackoverflow.com/questions/3590308/testing-if-a-line-has-a-point-within-a-triangle
  # tl;dr - by plugging in the corner points of the rectangle into the equation that describes the line from start to finish,
  # we can determine if all of the points lie on the same side of the line. If so, the path doesn't cross the barrier.
  # lineFunc should accept two params, x and y and return a number where negative indicates one side of the line,
  # positive indicates the other, with 0 indicating the point lies on the line. function(x,y) {...}
  intersectsLine: (lineFunc)->
    previousSign = null
    for corner in @corners
      number = lineFunc(corner.x, corner.y)
      return true if number is 0
      sign = if number < 0 then -1 else 1
      if not previousSign?
        previousSign = sign
      else if sign isnt previousSign
        return true
    return false

###
      *** User Interaction States ***
###

EmptyState =
  enter: ->
    @_view.setCursor "default-cursor"

AddAgentsState =
  enter: ->
    @_view.setCursor "add-agents"
  click: (evt) ->
    @addDefaultAgent evt.envX, evt.envY

## more states added by interactive/tool-button
