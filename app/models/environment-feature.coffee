Agent = require 'models/agent'

###
  The base class of an environment feature
###
module.exports = class EnvironmentFeature extends Agent
  _viewLayer: 0
  step: ->
    # NOOP

  _consumeResources: null
