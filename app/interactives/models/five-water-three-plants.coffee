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
env          = require 'environments/water-flowerboxes'

window.model =
  run: ->
    plantSpecies.defs.CAN_SEED = false

    @interactive = new Interactive
      environment: env
      addOrganismButtons: [
        {
          species: plantSpecies
          traits: [
            new Trait {name: "root size", default: 1}
            new Trait {name: "size", default: 5}
            new Trait {name: "mystery", default: 'X'}
          ]
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "root size", default: 5}
            new Trait {name: "size", default: 5}
            new Trait {name: "mystery", default: 'Y'}
          ]
        }
        {
          species: plantSpecies
          traits: [
            new Trait {name: "root size", default: 10}
            new Trait {name: "size", default: 5}
            new Trait {name: "mystery", default: 'Z'}
          ]
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

  setupDialogs: ->
    messageShown = false
    showMessage = (message) =>
      if not messageShown
        helpers.showMessage message, @env.getView().view.parentElement
        messageShown = true

    Events.addEventListener Environment.EVENTS.RESET, =>
      messageShown = false

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt)=>
      # age will not be 0 if it's an addition due to carrying
      messageShown = false if evt.detail.agent.get('age') is 0

    Events.addEventListener Environment.EVENTS.STEP, =>
      numWilted = 0
      numXFlowers = 0
      numYFlowers = 0
      numZFlowers = 0

      for agent in @env.agents
        if agent.get('age') <= agent.species.defs.MATURITY_AGE
          return # wait until all plants are mature before displaying dialogs

        if agent.get("health") < 0.99
          numWilted++

        if agent.get("has flowers")
          roots = agent.get("root size")
          if roots is 5
            numXFlowers++
          else if roots is 10
            numYFlowers++
          else
            numZFlowers++

      if numXFlowers >= 3 and numYFlowers >= 3 and numZFlowers >= 3
        if numWilted is 0
          showMessage("Good job! All your plants are in the right boxes.<br/>Take a picture of your model and go on to the next page.")
        else
          if numWilted > 1
            showMessage("You've got lots of healthy plants, but still a few wilted ones! Can you work out where they should go?")
          else
            showMessage("You've got lots of healthy plants, but still one wilted one! Can you work out where it should go?")
      else if numWilted > 0
        if numWilted > 1
          showMessage("Uh oh, " + numWilted + " of your plants are wilted! Try to find the right environment for them using the Carry button.")
        else
          showMessage("Uh oh, one of your plants is wilted! Try to find the right environment for it using the Carry button.")

window.onload = ->
  model.run()

  model.setupDialogs()
