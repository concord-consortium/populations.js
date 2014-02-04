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

    barriers = @barriers.slice()
    @barriers = []
    for barrier in (barriers || [])
      @addBarrier.apply this, barrier

    @agents = []
    @_rules = []

    @carriedAgent = null

    # re-map seasonLenths into end-dates for efficient access later
    @_totalSeasonLengths = [];
    @_totalSeasonLengths[i] = length + (@_totalSeasonLengths[i-1] || 0) for length, i in @seasonLengths

    @yearLength = @_totalSeasonLengths[3] || 0

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
    loc = agent.getLocation()
    if @isInBarrier loc.x, loc.y
      return false

    @agents.push(agent) unless @agents.indexOf(agent) != -1

  removeAgent: (agent)->
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

  getAgentAt: (x,y)->
    for agent in @agents
      if agent.getView().contains(x,y,@_view.stage)
        return agent
    return null

  addBarrier: (x, y, width, height) ->
    @barriers.push new Barrier x, y, width, height

  isInBarrier: (x, y) ->
    for barrier in @barriers
      if barrier.contains x, y
        return true
    return false

  pickUpAgent: (agent) ->
    @removeAgent(agent)
    @carriedAgent = agent

  dropCarriedAgent: ->
    @addAgent @carriedAgent
    @carriedAgent = null


  # Used for setting the default species and traits for
  # creating and adding agents.
  setDefaultAgentCreator: (@defaultSpecies, @defaultTraits) ->

  addDefaultAgent: (x, y) ->
    return unless @defaultSpecies?
    agent = @defaultSpecies.createAgent(@defaultTraits)
    agent.environment = @
    agent.setLocation x: x, y: y
    @addAgent agent

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
      a.step()
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
    if @_totalSeasonLengths.length == 4
      yearDate = @date % @yearLength
      for length, i in @_totalSeasonLengths
        if yearDate < length
          @season = SEASONS[i]; break

      if yearDate == @_totalSeasonLengths[2] # first day of winter
        @_view.addWinterImage()
      else if yearDate == @_totalSeasonLengths[3]-1 # last day of winter
        @_view.removeWinterImage()



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

  ### Events ###
  @EVENTS:
    STEP: "environment-step"

  ### UI States ###

  UI_STATE:
    NONE: "None"
    ADD_AGENTS: "Add Agents"

class Barrier
  constructor: (@x1, @y1, width, height) ->
    @x2 = @x1 + width
    @y2 = @y1 + height

  contains: (x, y) ->
    @x2 >= x >= @x1 and @y2 >= y >= @y1



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
    @addDefaultAgent evt.layerX, evt.layerY

## more states added by interactive/tool-button
