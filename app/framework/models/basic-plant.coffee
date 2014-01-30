Agent = require 'models/agent'
helpers = require 'helpers'

defaultProperties =
  'is seed': true
  'can seed': true
  'has flowers': false

###
	The base class of a simple plant
###
module.exports = class BasicPlant extends Agent

  _hasSeeded: false

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

  createSeeds: ->
    @reproduce()
    @_hasSeeded = true
    @set 'has flowers', false

  step: ->
    age     = @get 'age'
    season  = @get 'season'

    # seeds are frozen and do not start aging until spring
    if age is 0 and season isnt "spring"
      return

    @_incrementAge()

    if @get 'is seed'
      if age < @species.defs.SPROUT_AGE
        return
      else
        @set 'is seed', false

    if (!@_hasSeeded) and @species.defs.CAN_SEED
      if !@get('has flowers') and age > @species.defs.MATURITY_AGE and ((!@species.defs.IS_ANNUAL) || season isnt "fall")
        if Math.random() < @species.defs.CHANCE_OF_FLOWERING
          @set 'has flowers', true

      if @get 'has flowers'
        if @species.defs.IS_ANNUAL
          if season is "fall" and Math.random() < @species.defs.CHANCE_OF_SEEDING
            @createSeeds()
        else
          if Math.random() < @species.defs.CHANCE_OF_SEEDING
            @createSeeds()

    @_checkSurvival()