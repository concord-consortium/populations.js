require.register "species/plus-one", (exports, require, module) ->

  Species = require 'models/species'
  EnvironmentFeature = require 'models/environment-feature'

  module.exports = new Species
    speciesName: "plus one"
    agentClass: EnvironmentFeature
    defs: {}
    traits: []
    imageRules: [
      {
        name: 'plus one'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/hawks/hawkPlus1.png"
              scale: 0.2
              anchor:
                x: 0
                y: 1
              position:
                y: -11
          }
        ]
      }
    ]
