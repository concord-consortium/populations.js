require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'
ToolButton  = require 'interactive/tool-button'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/water-field'

window.model =
  run: ->
    plantSpecies.defs.CHANCE_OF_MUTATION = 0.3

    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          species: plantSpecies
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 1}
            new Trait {name: "mystery", default: 'Z'}
          ]
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

window.onload = ->
  model.run()
