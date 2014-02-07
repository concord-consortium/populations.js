helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
ToolButton  = require 'interactive/tool-button'
Events      = require 'events'

plantSpecies = require 'species/varied-plants'
env          = require 'environments/sunlight-3-flowerboxes'

window.model =
  run: ->
    plantSpecies.defs.CAN_SEED = false        # we'll script the seeding ourselves
    plantSpecies.addTrait new Trait {name: "is immortal", default: true}    # all plants are immortal

    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 5}
          ]
          limit: 1
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
        {
          type: ToolButton.CARRY_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies


  showMessage: (message) ->
    helpers.showMessage message, @env.getView().view.parentElement

window.onload = ->
  model.run()
