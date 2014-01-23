###
  A Trait is a property of a species, and all traits have a set of possible values.
  Each agent in a species has a specific value for each of these traits. This set
  is the agent's properties.

  For example, the species Plant might have the traits 
    "health": 0-1
    "number of leaves": 0, 2, 4
    "leaf color": ["green", "red"]

  and an individual plant agent might have the properties
    "health": 0.9
    "number of leaves": 2
    "leaf color": "green"

  The Trait class defines the allowed values for each trait and has helper methods for
  picking random values and mutating a value.
###

require 'helpers'

module.exports = class Trait

  constructor: ({@name, @possibleValues, @min, @max, @default, @float}) ->

  getDefaultValue: ->
    if @default? then @default
    else @getRandomValue()

  getRandomValue: ->
    if (@possibleValues)
      @possibleValues.randomElement()
    else
      if @float
        ExtMath.randomValue @min, @max
      else
        Math.floor ExtMath.randomValue @min, @max+1