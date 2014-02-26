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

plantSpecies  = require 'species/fast-plants-roots'
rabbitSpecies = require 'species/white-brown-rabbits'
hawkSpecies   = require 'species/hawks'
env           = require 'environments/snow'

window.model =
  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: true
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/grass/tallgrass.png"
          traits: [
            new Trait {name: "resource consumption rate", default: 2}
          ]
          limit: 50
          scatter: 10
        }
        {
          species: rabbitSpecies
          imagePath: "images/agents/rabbits/rabbit2.png"
          traits: [
            new Trait {name: "mating desire bonus", default: -20}
            new Trait {name: "hunger bonus", default: -10}
            new Trait {name: "metabolism", default: 0.1}
            new Trait {name: "resource consumption rate", default: 10}
            new Trait {name: "age", default: 1}
          ]
          limit: 30
          scatter: 30
        }
        {
          species: hawkSpecies
          imagePath: "images/agents/hawks/hawk.png"
          traits: [
            new Trait {name: "mating desire bonus", default: -15}
          ]
          limit: 2
          scatter: 2
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
    @hawkSpecies = hawkSpecies
    @rabbitSpecies = rabbitSpecies

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
        [255,   0,   0]
      ]

    @outputGraph = LabGrapher '#graph', outputOptions

    Events.addEventListener Environment.EVENTS.RESET, =>
      @outputGraph.reset()

    Events.addEventListener Environment.EVENTS.STEP, =>
      @outputGraph.addSamples @countRabbits()

  countRabbits: ->
    whiteRabbits = 0
    brownRabbits = 0
    for a in @env.agents
      whiteRabbits++ if a.species is @rabbitSpecies and a.get('color') is 'white'
      brownRabbits++ if a.species is @rabbitSpecies and a.get('color') is 'brown'
    return [whiteRabbits, brownRabbits]

  setupTimer: ->
    backgroundChangeable = false
    changeInterval = 5
    Events.addEventListener Environment.EVENTS.STEP, =>
      t = Math.floor(@env.date * Environment.DEFAULT_RUN_LOOP_DELAY / 1000) # this will calculate seconds at default speed
      if t % changeInterval is 0 and backgroundChangeable and t/changeInterval <= 9
        @changeBackground(t/changeInterval)
        backgroundChangeable = false
      else if t % changeInterval isnt 0
        backgroundChangeable = true

    Events.addEventListener Environment.EVENTS.RESET, =>
      @env.setBackground("images/environments/snow.png")

  changeBackground: (n)->
    return unless 0 < n < 10
    @env.setBackground("images/environments/snow-#{n}.png")

  showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

window.onload = ->
  model.run()
  model.setupGraph()
  model.setupTimer()
