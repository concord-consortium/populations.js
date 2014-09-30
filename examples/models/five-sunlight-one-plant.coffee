helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'

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
          imagePath: "images/agents/varied-plants/buttons/seedpack_10.png"
          traits: [
            new Trait {name: "size", default: 1}
          ]
          limit: 20
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies

    ### message script ###
    started     = false
    agentsAdded = 0
    allAreAdult = false
    hasFlower   = false
    shownNoFlowerMessage = false
    shownFlowerMessage   = false
    stepsSinceLastAgentAdded = 0

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt) =>
      agentsAdded++
      stepsSinceLastAgentAdded = 0
      if (agentsAdded == 20 and not started)
        @showMessage "You ran out of seeds! <br/><br/> Each seed packet only has 20 seeds. <br/>
                      Press play to start the model and watch your plants grow"

    Events.addEventListener Environment.EVENTS.STEP, =>
      if shownFlowerMessage then return

      started = true
      stepsSinceLastAgentAdded++

      allAreAdult = true
      for agent in env.agents
        if agent.get('age') < (plantSpecies.defs.MATURITY_AGE+20)
          allAreAdult = false
        if agent.get 'has flowers'
          hasFlower = true

      if not shownFlowerMessage and allAreAdult and hasFlower
        addMore = if agentsAdded < 20 then " Try planting the rest of your seeds in the other boxes." else ""
        @showMessage "Great! You found the right flower box for the plant.<br/><br/>
                      Look to see how much sun the plant needs to grow a flower."+addMore
        shownFlowerMessage = true
        return

      if not shownNoFlowerMessage and allAreAdult and not hasFlower and stepsSinceLastAgentAdded > 100
        @showMessage "You haven't yet found out which flower box is right for your plant.<br/><br/>
                      Try planting the rest of your seeds in the other boxes."
        shownNoFlowerMessage = true

    Events.addEventListener Environment.EVENTS.RESET, =>
      started     = false
      agentsAdded = 0
      allAreAdult = false
      hasFlower   = false
      shownNoFlowerMessage = false
      shownFlowerMessage   = false
      stepsSinceLastAgentAdded = 0


  showMessage: (message) ->
    helpers.showMessage message, @env.getView().view.parentElement

  preload: ["images/agents/varied-plants/buttons/seedpack_10.png"]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
