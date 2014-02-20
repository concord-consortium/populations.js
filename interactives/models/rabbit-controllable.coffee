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
    @rabbit.setLocation({x: 225, y: 225})
    @rabbit.set('is selected', true)
    @rabbit.set('is immortal', true)
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
      ymax:   50
      ymin:   0
      xTickCount: 15
      yTickCount: 5
      xFormatter: "2d"
      yFormatter: "2d"
      realTime: false
      fontScaleRelativeToParent: true
      sampleInterval: (@env._runLoopDelay/1000)
      dataType: 'samples'

    @outputGraph = Lab.grapher.Graph '#graph', outputOptions

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

    move = =>
      if @env._isRunning
        @rabbit.set 'speed', 20
        @rabbit.move()
        @rabbit.set 'speed', 0

    @up.onclick = =>
      @rabbit.set 'direction', 1.5 * Math.PI
      move()
      return false

    @down.onclick = =>
      @rabbit.set 'direction', 0.5 * Math.PI
      move()
      return false

    @left.onclick = =>
      @rabbit.set 'direction', Math.PI
      move()
      return false

    @right.onclick = =>
      @rabbit.set 'direction', 0
      move()
      return false

  setupTimer: ->
    time = document.getElementById('time-value')
    Events.addEventListener Environment.EVENTS.RESET, =>
      time.innerHTML = "0"

    Events.addEventListener Environment.EVENTS.STEP, =>
      t = Math.floor(@env.date * @env._runLoopDelay / 1000)
      time.innerHTML = "" + t
      if t >= 30
        @env.stop()
        @showMessage 'Congratulations! Your bunny was able to find enough food to live!'

  setupHungerSlider: ->
    slider = document.getElementById('hunger-slider')
    Events.addEventListener Environment.EVENTS.STEP, =>
      if @rabbit.isDead
        @env.stop()
        @showMessage 'The bunny died because it was not able to find enough food to live. Click Reset and try again!'
        return

      hunger = Math.round(100 - @rabbit.get('energy'))
      slider.innerHTML = "" + hunger

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
  model.run()
  model.setupGraph()
  model.setupControls()
  model.setupTimer()
  model.setupHungerSlider()
