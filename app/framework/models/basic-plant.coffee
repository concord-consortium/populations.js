Agent = require 'models/agent'

###
	The base class of a simple plant
###
module.exports = class BasicPlant extends Agent

  getSize: ->
    age = @get('age')
    if @species.defs.SPROUT_AGE and age < @species.defs.SPROUT_AGE
      1
    else if @species.defs.MATURITY_AGE
      maturity = @get('age') / @species.defs.MATURITY_AGE
      Math.min maturity, 1
    else
      1