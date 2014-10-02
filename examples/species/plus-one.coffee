require.register "species/plus-one", (exports, require, module) ->

  Species = require 'models/species'
  Inanimate = require 'models/inanimate'

  module.exports = new Species
    speciesName: "plus one"
    agentClass: Inanimate
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
