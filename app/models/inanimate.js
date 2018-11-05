Agent = require 'models/agent'

###
  The base class of an inanimate object
###
module.exports = class Inanimate extends Agent
  label: "inanimate"
  _viewLayer: 0
  step: ->
    undefined

  _consumeResources: null
