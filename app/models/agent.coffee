AgentView = require 'views/agent-view'
helpers   = require 'helpers'

defaultProperties =
  'min offspring': 1
  'max offspring': 3
  'min offspring distance': 10
  'max offspring distance': 40
  'health': 1
  'is immortal': false

###
  The base agent class
###
module.exports = class Agent
  label: "organism"
  bred: false
  _viewLayer: 1

  constructor: ({@name, @environment, @species, x, y, additionalDefaults}) ->
    @_props = helpers.clone defaultProperties
    @_props = helpers.setDefaults(@_props, additionalDefaults) if additionalDefaults?
    @_view = new AgentView({agent: @})
    if x? && y?
      @setLocation({x,y})
    @makeNewborn()

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
    if @hasProp(prop) then val = @_props[prop]
    else val = @getEnvironmentProperty prop

    if !val? then throw "Cannot find property "+prop
    return val

  hasProp: (prop) ->
    return @_props[prop]?

  getAllProperties: ->
    return @_props

  getEnvironmentProperty: (prop) ->
    return null unless @environment?
    @environment.getAt @_x, @_y, prop

  setEnvironmentProperty: (prop, val) ->
    return unless @environment?
    @environment.setAt @_x, @_y, prop, val

  getImages: (opts = {})->
    @species.getImages this, opts

  getSize: ->
    if @species.defs.MATURITY_AGE
      maturity = @get('age') / @species.defs.MATURITY_AGE
      Math.min maturity, 1
    else
      1

  isDead: false

  die: ->
    @isDead = true

  step: ->
    @_incrementAge()
    @_checkSurvival()

  makeNewborn: ->
    @set('age', 0)

  ###
    Creates one or more offspring, depending on the min- and max- offspring
    properties, and places them in the environment.

    Returns the array of offspring.

    Only asexual for now
  ###
  reproduce: (mate) ->
    minOffspring = @get 'min offspring'
    maxOffspring = @get 'max offspring'
    numOffspring = minOffspring + ExtMath.randomInt(1 + maxOffspring - minOffspring)

    for i in [0...numOffspring]
      @createOffspring(mate)

  ###
    Returns an offspring and places it in the environment

    Only asexual reproduction for now
  ###
  createOffspring: (mate) ->
    offspring = @_clone()
    offspring._mutate();
    offspring.makeNewborn()
    offspring.bred = true

    if @environment
      offspring.setLocation @_findOffspringLocation()
      @environment.addAgent offspring

    return offspring

  _clone: ->
    clone = @species.createAgent()
    for prop of @_props
      clone.set prop, @_props[prop]
    return clone

  _mutate: ->
    for trait in @species.traits
      if trait.mutatable and Math.random() < @species.defs.CHANCE_OF_MUTATION
        currentVal = @get trait.name
        mutatedVal = trait.mutate currentVal
        @set trait.name, mutatedVal

  _findOffspringLocation: () ->
    loc = @getLocation()

    minD = @get 'min offspring distance'
    maxD = @get 'max offspring distance'

    distance = ExtMath.randomValue minD, maxD
    angle    = Math.random() * 2 * Math.PI

    xStep = Math.floor distance * Math.sin angle
    yStep = Math.floor distance * Math.cos angle

    return {x: loc.x + xStep, y: loc.y + yStep}


  _incrementAge: ->
    @set('age', @get('age')+1)

  _consumeResources: ->

  _checkSurvival: ->
    chance = if @hasProp('chance of survival') then @get('chance of survival') else @_getSurvivalChances()
    @die() if Math.random() > chance

  _getSurvivalChances: ->
    return 1.0 if @get('is immortal')

    age = @get('age')
    ageMax = @species.defs.MAX_AGE || 2000

    agePct = 1 - (age/ageMax)

    # TODO factor in HUNGER
    # p2 = Math.pow(hungerPct, 2)
    healthPct = @get('health')/@species.defs.MAX_HEALTH

    return agePct * healthPct

