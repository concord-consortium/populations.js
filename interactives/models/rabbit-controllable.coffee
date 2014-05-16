helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'
ToolButton  = require 'interactive/tool-button'
BasicAnimal = require 'models/basic-animal'

plantSpecies  = require 'species/fast-plants-thin'
rabbitSpecies = require 'species/white-rabbits'
env           = require 'environments/grass-field'

window.model =
  rabbit: null
  setupEnvironment: ->
    for i in [0..21]
      plant = plantSpecies.createAgent()
      plant.set("food quantity",100)
      plant.set("max offspring distance", 200)
      plant.set("min offspring", 1)
      plant.set("max offspring", 2)
      plant.setLocation @env.randomLocation()
      @env.addAgent plant

    @rabbit = rabbitSpecies.createAgent()
    @rabbit.setLocation @env.randomLocation()
    @rabbit.set('is selected', true)
    @rabbit.set('is immortal', true)
    @rabbit.set('age', 20)
    @rabbit.set('speed', 0)
    @rabbit.set('default speed', 0)
    @rabbit.set('calculate drives', false)
    @rabbit.set('current behavior', BasicAnimal.BEHAVIOR.WANDERING)
    @env.addAgent @rabbit

  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: []
      toolButtons: []

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies
    @rabbitSpecies = rabbitSpecies

    @setupEnvironment()

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()

  setupGraph: ->
    outputOptions =
      title:  "Number of plants in field"
      xlabel: "Time (s)"
      ylabel: "Number of plants"
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

    @outputGraph = LabGrapher '#graph', outputOptions

    # start the graph at 0,22
    @outputGraph.addSamples [22]

    Events.addEventListener Environment.EVENTS.RESET, =>
      @outputGraph.reset()
      @outputGraph.addSamples [22]

    Events.addEventListener Environment.EVENTS.STEP, =>
      plants = 0
      for a in @env.agents
        plants++ if a.species is @plantSpecies
      @outputGraph.addSamples [plants]

  setupControls: ->
    @up = document.getElementById('up')
    @down = document.getElementById('down')
    @left = document.getElementById('left')
    @right = document.getElementById('right')

    move = (direction)=>
      @rabbit.set 'direction', direction
      if @env._isRunning
        @rabbit.set 'speed', 20
        @rabbit.move()
        @rabbit.set 'speed', 0
      return false

    @up.onclick = =>
      return move(1.5 * Math.PI)
    @up.ontouchstart = (evt)=>
      evt.preventDefault()
      return move(1.5 * Math.PI)

    @down.onclick = =>
      return move(0.5 * Math.PI)
    @down.ontouchstart = (evt)=>
      evt.preventDefault()
      return move(0.5 * Math.PI)

    @left.onclick = =>
      return move(Math.PI)
    @left.ontouchstart = (evt)=>
      evt.preventDefault()
      return move(Math.PI)

    @right.onclick = =>
      return move(0)
    @right.ontouchstart = (evt)=>
      evt.preventDefault()
      return move(0)

  setupTimer: ->
    time = document.getElementById('time-value')
    Events.addEventListener Environment.EVENTS.RESET, =>
      time.innerHTML = "0"

    Events.addEventListener Environment.EVENTS.STEP, =>
      t = Math.floor(@env.date * Environment.DEFAULT_RUN_LOOP_DELAY / 1000) # this will calculate seconds at default speed
      time.innerHTML = "" + t
      if t >= 30
        @env.stop()
        @showMessage 'Congratulations! Your bunny was able to find enough food to live!'

  setupHungerSlider: ->
    slider = document.getElementById('hunger-slider')
    ppslider = $(slider).PPSlider({height: 150, vertical: true, minLabel: 'Not hungry', maxLabel: 'Very hungry', moveable: false})
    Events.addEventListener Environment.EVENTS.STEP, =>
      if @rabbit.isDead
        @env.stop()
        @showMessage 'The bunny died because it was not able to find enough food to live. Click Reset and try again!'
        return

      hunger = Math.round(100 - @rabbit.get('energy'))
      ppslider.updatePositionByValue(hunger)

      if hunger > 99
        @rabbit.die()
        return

      if hunger > 70
        @rabbit.set('bubble showing', 'food')
      else
        @rabbit.set('bubble showing', 'none')

      if hunger > 5
        @rabbit.set('current behavior', BasicAnimal.BEHAVIOR.EATING)
      else
        @rabbit.set('current behavior', BasicAnimal.BEHAVIOR.WANDERING)


  showMessage: (message, pause=false) ->
    helpers.showMessage message, @env.getView().view.parentElement

window.onload = ->
  helpers.preload [env, plantSpecies, rabbitSpecies], ->
    model.run()
    model.setupGraph()
    model.setupControls()
    model.setupTimer()
    model.setupHungerSlider()
