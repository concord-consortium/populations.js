helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'
ToolButton  = require 'interactive/tool-button'

plantSpecies  = require 'species/fast-plants-thin'
rabbitSpecies = require 'species/white-rabbits'
env           = require 'environments/grass-field'

window.model =
  setupEnvironment: ->
    for i in [0..21]
      plant = plantSpecies.createAgent()
      plant.set("food quantity",100)
      plant.set("max offspring distance", 200)
      plant.set("min offspring", 1)
      plant.set("max offspring", 2)
      plant.setLocation @env.randomLocation()
      @env.addAgent plant

    rabbit = rabbitSpecies.createAgent()
    rabbit.setLocation({x: 225, y: 225})
    rabbit.set('is selected', true)
    rabbit.set('is immortal', true)
    @env.addAgent rabbit

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

    Events.addEventListener Environment.EVENTS.STEP, =>
      # TODO Track countdown timer, etc.

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

  showMessage: (message, pause=false) ->
    if pause then @env.stop()
    helpers.showMessage message, @env.getView().view.parentElement, =>
      @env.start()

window.onload = ->
  model.run()
  model.setupGraph()
