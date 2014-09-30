helpers     = require 'helpers'

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
    plantSpecies.setMutatable 'size', false

    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/varied-plants/buttons/seedpack_z.png"
          traits: [
            new Trait {name: "size", default: 5}
            new Trait {name: "root size", default: 1}
          ]
          limit: 15
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

    startingMoney = 20
    moneyLeft = 20
    updateMoney = (val)->
      moneyLeft = val
      document.getElementById('money-value').innerHTML = "$"+val

    Events.addEventListener Environment.EVENTS.RESET, ->
      updateMoney(startingMoney)

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt)->
      updateMoney(moneyLeft-1) unless evt.detail.agent.bred

  preload: [
    "images/agents/varied-plants/buttons/seedpack_z.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
