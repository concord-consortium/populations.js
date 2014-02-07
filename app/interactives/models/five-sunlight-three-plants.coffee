require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/sunlight-flowerboxes'

window.model = 
  run: ->
    plantSpecies.defs.CAN_SEED = false

    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 1}
            new Trait {name: "root size", default: 5}
          ]
          limit: 20
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 5}
          ]
          limit: 20
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 9}
            new Trait {name: "root size", default: 5}
          ]
          limit: 20
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

window.onload = ->
  model.run()
