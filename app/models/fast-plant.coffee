Agent = require 'models/agent'
helpers = require 'helpers'

defaultProperties =
  'growth rate': 0.5
  'resource consumption rate': 1
  'min offspring': 1
  'max offspring': 2
  'max offspring distance': 150
  'food quantity': 20
  'resource deficit': 0

###
  The base class of a simple plant
###
module.exports = class FastPlant extends Agent
  label: 'plant'

  _hasSeeded: false

  constructor: (args) ->
    super(args)
    # FastPlant defaults take priority over Agent defaults
    @_props = helpers.setDefaults(defaultProperties, @_props)

  getSize: ->
    1

  makeNewborn: ->
    @set('age', 10)
    @set('chance of survival', 1.0)
    @set('resource deficit', 0)

  step: ->
    food = @getEnvironmentProperty 'food'
    if food > 0
      if ExtMath.randomFloat(1) < @get 'growth rate'
        @reproduce()

    @_checkSurvival()

  _consumeResources: ->
    food = @getEnvironmentProperty('food')
    consumption = @get('resource consumption rate')
    if food >= consumption
      @setEnvironmentProperty('food', food - consumption)
      @set('resource deficit', 0)
    else
      underfed = consumption - food
      currDeficit = @get('resource deficit')
      @set('resource deficit', currDeficit + underfed)
      @setEnvironmentProperty('food', 0)

  _checkSurvival: ->
    chance = @get('chance of survival')
    if ExtMath.randomFloat(1) > chance
      @die()
