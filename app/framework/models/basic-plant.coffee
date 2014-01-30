Agent = require 'models/agent'
helpers = require 'helpers'

defaultProperties =
  'can seed': true
  'has flowers': false
  'chance of seeding': 0.2

###
	The base class of a simple plant
###
module.exports = class BasicPlant extends Agent

  constructor: (args) ->
    super(args)
    @_props = helpers.setDefaults(@_props, defaultProperties)

  getSize: ->
    age = @get('age')
    if @species.defs.SPROUT_AGE and age < @species.defs.SPROUT_AGE
      1
    else if @species.defs.MATURITY_AGE
      maturity = @get('age') / @species.defs.MATURITY_AGE
      Math.min maturity, 1
    else
      1

  makeNewborn: ->
    super()
    @set 'has flowers', false

  step: ->
    @_incrementAge()

    if @get 'can seed'
      if @species.defs.MATURITY_AGE
        if @get('age') > @species.defs.MATURITY_AGE && Math.random() < @get('chance of seeding')
          minOffspring = @get 'min offspring'
          maxOffspring = @get 'max offspring'
          numOffspring = minOffspring + ExtMath.randomInt(1 + maxOffspring - minOffspring)

          for i in [0...numOffspring]
           @reproduce()

    @_checkSurvival()