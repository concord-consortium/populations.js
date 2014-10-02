helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'
BasicAnimal = require 'models/agents/basic-animal'

plantSpecies  = require 'species/fast-plants-roots'
rabbitSpecies = require 'species/white-brown-rabbits'
hawkSpecies   = require 'species/hawks'
plusOne       = require 'species/plus-one'
env           = require 'environments/snow'

window.model =
  hawk: null
  startingPlants: 200
  startingRabbits: 25
  setupEnvironment: ->
    for i in [1..@startingPlants]
      plant = plantSpecies.createAgent()
      plant.setLocation @env.randomLocation()
      @env.addAgent plant

    for color in ['white', 'brown']
      for i in [1..@startingRabbits]
        rabbit = rabbitSpecies.createAgent()
        rabbit.set 'age', 10
        rabbit.set 'mating desire bonus', 10
        rabbit.set 'hunger bonus', -10
        rabbit.set 'resource consumption rate', 10
        rabbit.set 'fear bonus', -1000
        rabbit.set 'color', color
        rabbit.setLocation @env.randomLocation()
        @env.addAgent rabbit

    @hawk = hawkSpecies.createAgent()
    @hawk._viewLayer = 5
    @hawk.setLocation @env.randomLocation()
    @hawk.set 'is immortal', true
    @hawk.set 'age', 20
    @hawk.set 'speed', 0
    @hawk.set 'default speed', 0
    @hawk.set 'calculate drives', false
    @hawk.set 'wings', 0
    @hawk.set 'current behavior', BasicAnimal.BEHAVIOR.WANDERING
    @env.addAgent @hawk

  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: []
      toolButtons: []

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies
    @hawkSpecies = hawkSpecies
    @rabbitSpecies = rabbitSpecies
    @plusOne = plusOne

    @setupEnvironment()

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()

  setupGraph: ->
    outputOptions =
      title:  "Number of rabbits"
      xlabel: "Time (s)"
      ylabel: "Number of rabbits"
      xmax:   30
      xmin:   0
      ymax:   80
      ymin:   0
      xTickCount: 15
      yTickCount: 8
      xFormatter: "2d"
      yFormatter: "2d"
      realTime: false
      fontScaleRelativeToParent: true
      sampleInterval: (Environment.DEFAULT_RUN_LOOP_DELAY/1000)
      dataType: 'samples'
      dataColors: [
        [153, 153, 153]
        [153,  85,   0]
      ]

    @outputGraph = LabGrapher '#graph', outputOptions

    # start the graph at 0,22
    @outputGraph.addSamples [@startingRabbits,@startingRabbits]

    Events.addEventListener Environment.EVENTS.RESET, =>
      @outputGraph.reset()
      @outputGraph.addSamples [@startingRabbits,@startingRabbits]

    Events.addEventListener Environment.EVENTS.STEP, =>
      whiteRabbits = 0
      brownRabbits = 0
      for a in @env.agents
        whiteRabbits++ if a.species is @rabbitSpecies and a.get('color') is 'white'
        brownRabbits++ if a.species is @rabbitSpecies and a.get('color') is 'brown'
      @outputGraph.addSamples [whiteRabbits, brownRabbits]

  numEaten: 0
  brownEaten: 0
  whiteEaten: 0
  setupControls: ->
    @env.addState 'hawk-follow-mouse',
      click: (evt)=>
        @hawk.setLocation {x: evt.envX, y: evt.envY}
        @hawk.set 'wings', 1
        @_tryToEat()
        setTimeout =>
          @hawk.set 'wings', 0
        , 200

      mousemove: (evt)=>
        @hawk.setLocation {x: evt.envX, y: evt.envY}
    @env.setState 'hawk-follow-mouse'

    caughtElem = document.getElementById('caught-value')
    Events.addEventListener Environment.EVENTS.RESET, =>
      @env.setState 'hawk-follow-mouse'
      @numEaten = 0
      @brownEaten = 0
      @whiteEaten = 0
      caughtElem.innerHTML = "0"

    Events.addEventListener Environment.EVENTS.AGENT_EATEN, (evt)=>
      if evt.detail.predator is @hawk
        @_createPlusOne()
        @numEaten++
        @brownEaten++ if evt.detail.prey.get('color') is 'brown'
        @whiteEaten++ if evt.detail.prey.get('color') is 'white'
        caughtElem.innerHTML = "" + @numEaten

  _tryToEat: ->
    nearest = @hawk._nearestPrey()
    if nearest?
      eatingDist = @hawk.get('eating distance')
      if nearest.distanceSq < Math.pow(eatingDist, 2)
        color = nearest.agent.get('color')
        if color is 'brown' or ExtMath.flip() is 1
          @hawk._eatPrey(nearest.agent)

  _createPlusOne: ->
    plus = @plusOne.createAgent()
    plus.setLocation @hawk.getLocation()
    @env.addAgent plus
    setTimeout ->
      plus.die()
    , 1000

  _numRabbits: ->
    count = 0
    for a in @env.agents
      count++ if a.species is @rabbitSpecies
    return count

  setupTimer: ->
    Events.addEventListener Environment.EVENTS.STEP, =>
      t = Math.floor(@env.date * Environment.DEFAULT_RUN_LOOP_DELAY / 1000) # this will calculate seconds at default speed
      if t >= 30 or @_numRabbits() is 0
        @env.stop()
        if @numEaten is 0
          @showMessage "Oh no, you didn't catch any rabbits!<br/>Press Reset to try again, and be sure to click on the rabbits to eat them."
        else
          @showMessage "Good job! You caught #{@numEaten} rabbits!<br/>You caught #{@whiteEaten} white rabbits and #{@brownEaten} brown rabbits.", =>
            @showMessage "Take a picture of the graph. Then continue on."

  showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

window.onload = ->
  helpers.preload [env, plantSpecies, rabbitSpecies, hawkSpecies, plusOne], ->
    model.run()
    model.setupGraph()
    model.setupControls()
    model.setupTimer()
