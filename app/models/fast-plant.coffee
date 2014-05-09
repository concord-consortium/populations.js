Agent = require 'models/agent'
helpers = require 'helpers'

defaultProperties =
  'growth rate': 0.5
  'min offspring': 1
  'max offspring': 2
  'max offspring distance': 150
  'food quantity': 20

###
  The base class of a simple plant
###
module.exports = class FastPlant extends Agent
  label: 'plant'

  _hasSeeded: false

  constructor: (args) ->
    super(args)
    # FastPlant defaults take priority over Agent defaults
    @_props = helpers.setDefaults(helpers.clone(defaultProperties), @_props)

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

  _checkSurvival: ->
    chance = @get('chance of survival')
    if ExtMath.randomFloat(1) > chance
      @die()
