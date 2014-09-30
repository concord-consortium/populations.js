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
            new Trait {name: "gen", default: 1}
            new Trait {name: "complete", default: false}
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


  setupDialogs: ->
    yearCount = message1StepCount = message2StepCount = message3StepCount = message4StepCount =
    waitingForMessage1 = waitingForMessage2 = waitingForMessage3 = waitingForMessage4 =
    makeSeedsCount = readyToMakeSeeds = popSize = generation = previousHealth =
    shownNoMorePlantsMessage = shownWiltedMessage = shownTwoWiltedMessage = atLeastOneAgentAdded = null
    initializeVariables = =>
      @env.usingSeasons = true
      yearCount = 0
      message1StepCount = 0
      message2StepCount = 0
      message3StepCount = 0
      message4StepCount = 0
      waitingForMessage1 = false
      waitingForMessage2 = false
      waitingForMessage3 = false
      waitingForMessage4 = false
      makeSeedsCount = 0
      readyToMakeSeeds = false
      popSize = -1
      generation = 1
      previousHealth = -1
      shownNoMorePlantsMessage = false
      shownWiltedMessage = false
      shownTwoWiltedMessage = false
      atLeastOneAgentAdded = false
    initializeVariables()

    showMessage = (message) =>
      @env.stop()
      helpers.showMessage message, @env.getView().view.parentElement, =>
        @env.start()

    Events.addEventListener Environment.EVENTS.RESET, ->
      initializeVariables()

    Events.addEventListener Environment.EVENTS.SEASON_CHANGED, =>
      agents = @env.agents
      if agents.length > 0
        firstAgent = @env.agents[0]
        season = @env.season
        if season is "summer"
          yearCount++
        if firstAgent.get("gen") is 1
          if firstAgent.get("health") < 1.0    # seed planted in the wrong place
            if season is "summer"
              if !shownWiltedMessage
                showMessage("You planted your seed in a flowerbox where the light level is wrong for it.\n" +
                "It won't make a flower and it won't drop any seeds.")
                shownWiltedMessage = true
              waitingForMessage3 = true
            else if season is "winter" and waitingForMessage3
              firstAgent.set('is immortal', false)
          else if season is "fall" and firstAgent.get('has flowers')
            readyToMakeSeeds = true
        else if firstAgent.get("gen") is 2 and !firstAgent.get("complete")            # second generation
          if season is "summer"
            if !shownTwoWiltedMessage
              waitingForMessage1 = true
          else if season is "fall"
            waitingForMessage2 = true
            waitingForMessage4 = true

    onTopOfSomeone = (x1, y1)=>
      for otherAgent in @env.agents
        x2 = otherAgent.getLocation().x
        y2 = otherAgent.getLocation().y
        if Math.abs(x1 - x2) < 20
          return true
      return false

    setLocation = (parent, child)=>
      xLocParent = 100  # left edge of the flower box
      yLocParent = parent.getLocation().y
      tries = 0
      while true
        tries++
        xLocChild = xLocParent + ExtMath.randomInt(400) + 20
        yLocChild = yLocParent - 5 + ExtMath.randomInt(10)
        unless tries < 20 and (@env.isInBarrier(xLocChild, yLocChild) or onTopOfSomeone(xLocChild, yLocChild))
          # console.log("gave up") if tries >= 20
          child.setLocation({x: xLocChild, y: yLocChild})
          return

    makeSeeds = (agent)=>
      agent.set("has flowers", false)
      generation = 2

      while @env.agents.length < 7
        i = @env.agents.length
        child = agent.createOffspring()
        child.set('gen', 2)
        child.set('is immortal', true)
        if i < 5
          child.set('size', 5)
        else if i < 6
          child.set('size', 4)
        else if i < 7
          child.set('size', 6)
        setLocation(agent, child)

    allAgentsAreHealthy = (agents)=>
      return false if @env.carriedAgent?
      for agent in agents
        health = agent.get("health")
        if health < 0.99
          return false
      return true

    Events.addEventListener Environment.EVENTS.STEP, =>
      agents = @env.agents
      if agents.length > 0
        atLeastOneAgentAdded = true

      if agents.length is 0
        if !atLeastOneAgentAdded
          @env.date = 0   # don't start counting days until a seed is planted
          return

        if !shownNoMorePlantsMessage and atLeastOneAgentAdded and !@env.carriedAgent?
          if waitingForMessage3
            showMessage "Your plant wilted and died, and left no seeds so no new plants will grow.\n Hit 'reset' and try again."
          else
            showMessage "You have no more plants!\n If you want to restart, click the Restart button."
          shownNoMorePlantsMessage = true
        return

      if agents.length < popSize and agents.length < 6 and !@env.carriedAgent?
        showMessage "Uh oh, you dropped a plant in between the flower boxes and it died!\n If you want to restart, click the Restart button."
        popSize = agents.length
        return

      popSize = agents.length

      if generation is 1
        firstAgent = agents[0]

        if readyToMakeSeeds
          makeSeedsCount++
          if makeSeedsCount is 10
            firstAgent.set("is immortal", false)
            firstAgent.set("has flowers", false)
            makeSeeds(firstAgent)

      if waitingForMessage1
        message1StepCount++;
        if message1StepCount is 15
          season = @env.season
          showMessage "Two of the new plants are wilted.\nUse the Information Tool to look at the plants more closely.\nDo all the plants have the same leaf size?"
          message1StepCount = 0
          waitingForMessage1 = false
          shownTwoWiltedMessage = true

      if waitingForMessage2
        message2StepCount++
        if message2StepCount is 50
          if !allAgentsAreHealthy(agents)
            showMessage "Try moving your wilted plants to different flowerboxes and see what happens."
          message2StepCount = 0
          waitingForMessage2 = false

          @env.usingSeasons = false

      if waitingForMessage4
        if allAgentsAreHealthy(agents)
          message4StepCount++
        if message4StepCount is 16
          if @env.agents.length is 6
            showMessage "Good job! Each of your plants is in an environment that makes it healthy!\nIf you want to experiment again, you can reset the model,\nor you can continue on."
          else
            showMessage "Each of your plants is in an environment that makes it healthy!\nHowever, some of your plants were dropped between flower boxes.\nIf you want to try again to make all six plants healthy, you can reset the model."
          waitingForMessage4 = false
          for agent in agents
            agent.set("complete", true)

  preload: ["images/agents/varied-plants/buttons/seedpack_6.png"]

window.onload = ->
  helpers.preload [model, env, plantSpecies], ->
    model.run()
    model.setupDialogs()
