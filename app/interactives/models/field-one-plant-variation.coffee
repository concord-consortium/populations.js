require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/sunlight-field'

window.model = 
  run: ->
    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 5}
          ]
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

window.onload = ->
  model.run()
