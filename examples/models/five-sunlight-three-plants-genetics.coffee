helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'

plantSpecies = require 'species/varied-plants-with-genetics'
env          = require 'environments/sunlight-flowerboxes'

window.model =
  run: ->
    plantSpecies.defs.CAN_SEED = false

    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_10.png"
          traits: [
            new Trait {name: "size", default: "a:L1,b:L1", isGenetic: true, isNumeric: true}
            new Trait {name: "root size", default: "a:R1,b:R4", isGenetic: true, isNumeric: true}
          ]
          limit: 20
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png"
          traits: [
            new Trait {name: "size", default: "a:L1,b:L4", isGenetic: true, isNumeric: true}
            new Trait {name: "root size", default: "a:R1,b:R4", isGenetic: true, isNumeric: true}
          ]
          limit: 20
        }
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_2.png"
          traits: [
            new Trait {name: "size", default: "a:L3,b:L4", isGenetic: true, isNumeric: true}
            new Trait {name: "root size", default: "a:R1,b:R4", isGenetic: true, isNumeric: true}
          ]
          limit: 20
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

  preload: [
    "images/agents/varied-plants/buttons/seedpack_2.png",
    "images/agents/varied-plants/buttons/seedpack_6.png",
    "images/agents/varied-plants/buttons/seedpack_10.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
