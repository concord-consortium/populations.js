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
foxSpecies    = require 'species/foxes'
env           = require 'environments/open'

window.model =
  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: [
        {
          species: plantSpecies
          imagePath: "images/agents/grass/tallgrass.png"
          traits: [
            new Trait {name: 'resource consumption rate', default: 2}
          ]
          limit: 4000
          scatter: 400
          showRemoveButton: true
        }
        {
          species: rabbitSpecies
          imagePath: "images/agents/rabbits/rabbit2.png"
          traits: [
            new Trait {name: "mating desire bonus", default: -20}
            new Trait {name: "hunger bonus", default: -10}
            new Trait {name: "age", default: 3}
            new Trait {name: "resource consumption rate", default: 10}
            new Trait {name: "min offspring", default: 3}
            new Trait {name: "max offspring", default: 10}
            new Trait {name: "metabolism", default: 1}
            new Trait {name: "chance of being seen", default: 0.17}
            new Trait {name: "mating distance", default: 250}
            new Trait {name: "vision distance", default: 500}
            new Trait {name: "color", default: "white"}
          ]
          limit: 700
          scatter: 70
          showRemoveButton: true
        }
        {
          species: hawkSpecies
          imagePath: "images/agents/hawks/hawk.png"
          traits: [
            new Trait {name: "min offspring", default: 2}
            new Trait {name: "max offspring", default: 4}
            new Trait {name: "mating distance", default: 140}
            new Trait {name: "eating distance", default:  50}
            new Trait {name: "vision distance", default: 350}
            new Trait {name: "metabolism", default: 6}
          ]
          limit: 150
          scatter: 6
          showRemoveButton: true
        }
        {
          species: foxSpecies
          imagePath: "images/agents/foxes/fox.png"
          traits: [
            new Trait {name: "max offspring", default: 3}
            new Trait {name: "mating distance", default: 220}
            new Trait {name: "eating distance", default:  50}
            new Trait {name: "metabolism", default: 3}
          ]
          limit: 140
          scatter: 6
          showRemoveButton: true
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies  = plantSpecies
    @hawkSpecies   = hawkSpecies
    @rabbitSpecies = rabbitSpecies
    @foxSpecies    = foxSpecies

  setupGraph: ->
    outputOptions =
      title:  "Number of organisms"
      xlabel: "Time (s)"
      ylabel: "Number of organisms"
      xmax:   100
      xmin:   0
      ymax:   50
      ymin:   0
      xTickCount: 10
      yTickCount: 10
      xFormatter: "2d"
      yFormatter: "2d"
      realTime: false
      fontScaleRelativeToParent: true
      sampleInterval: (Environment.DEFAULT_RUN_LOOP_DELAY/1000)
      dataType: 'samples'
      dataColors: [
        [  0, 170,   0]
        [153, 153, 187]
        [163,  31,   5]
        [222, 183,   9]
      ]

    @outputGraph = LabGrapher '#graph', outputOptions

    Events.addEventListener Environment.EVENTS.RESET, =>
      @outputGraph.reset()

    Events.addEventListener Environment.EVENTS.STEP, =>
      @outputGraph.addSamples @_countOrganisms()

  _countOrganisms: ->
    plants = 0
    rabbits = 0
    hawks = 0
    foxes = 0
    for a in @env.agents
      switch a.species
        when @plantSpecies
          plants++
        when @rabbitSpecies
          rabbits++
        when @hawkSpecies
          hawks++
        when @foxSpecies
          foxes++
    return [plants, rabbits, hawks, foxes]

  _showMessage: (message, callback) ->
    helpers.showMessage message, @env.getView().view.parentElement, callback

  _agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  _addedHawks: false
  _hawksAreDead: false
  _hawksRemoved: false
  _addedRabbits: false
  _rabbitsAreDead: false
  _rabbitsRemoved: false
  _endMessageShown: false
  _timeOfExtinction: 0
  setupPopulationControls: ->
    Events.addEventListener Environment.EVENTS.STEP, =>
      allRabbits = @_agentsOfSpecies @rabbitSpecies
      allHawks = @_agentsOfSpecies @hawkSpecies
      @_checkExtinction allRabbits, allHawks

      allFoxes = @_agentsOfSpecies @foxSpecies
      @_checkPredators allHawks, allFoxes

      if (@env.date + 1) % 350 is 0
        @_showEndMessage()
    Events.addEventListener Environment.EVENTS.RESET, =>
      @_showEndMessage() unless @_endMessageShown
      @_hawksRemoved = @_rabbitsRemoved = @_hawksAreDead = @_rabbitsAreDead = @_endMessageShown = @_addedRabbits = @_addedHawks = false
      @_timeOfExtinction = 0
    Events.addEventListener Environment.EVENTS.USER_REMOVED_AGENTS, (evt)=>
      species = evt.detail.species
      if species is @hawkSpecies
        @_hawksRemoved = true
      else if species is @rabbitSpecies
        @_rabbitsRemoved = true

  _showEndMessage: ->
    popupText = "If you've been able to discover what happens in the model, you can continue on.\n\n"+
                     "If not, you can keep running the model, or reset it if you want to run a new model."

    @_showMessage popupText
    @env.stop()
    @_endMessageShown = true

  _checkExtinction: (allRabbits, allHawks)->
    if allRabbits.length > 0
      @_addedRabbits = true
      @_rabbitsRemoved = false
      @_rabbitsAreDead = false

    if allHawks.length > 0
      @_addedHawks = true
      @_hawksRemoved = false
      @_hawksAreDead = false

    if @_hawksAreDead or @_rabbitsAreDead
      if @env.date is (@_timeOfExtinction + 20)
        if (@_hawksAreDead and !@_hawksRemoved) or (@_rabbitsAreDead and !@_rabbitsRemoved)
          @_showEndMessage()
    # else if @_addedHawks and @_hawksRemoved
    #   if allHawks.length is 0
    #     @_hawksAreDead = true
    #     @_timeOfExtinction = @env.date
    else if @_addedRabbits
      if allRabbits.length is 0
        @_rabbitsAreDead = true
        @_timeOfExtinction = @env.date

  _setProperty: (agents, property, value)->
    for agent in agents
      agent.set property, value

  _checkPredators: (allHawks, allFoxes)->
    if allHawks.length > 16
      @_setProperty allHawks, "min offspring", 0
      @_setProperty allHawks, "max offspring", 1
      @_setProperty allHawks, "metabolism", 8
    else if allHawks.length < 8
      @_setProperty allHawks, "min offspring", 3
      @_setProperty allHawks, "max offspring", 4
      @_setProperty allHawks, "metabolism", 4
    else
      @_setProperty allHawks, "min offspring", 2
      @_setProperty allHawks, "max offspring", 3
      @_setProperty allHawks, "metabolism", 6

    if allFoxes.length > 22
      @_setProperty allFoxes, "min offspring", 0
      @_setProperty allFoxes, "max offspring", 1
      @_setProperty allFoxes, "metabolism", 6
    else if allFoxes.length < 10
      @_setProperty allFoxes, "min offspring", 3
      @_setProperty allFoxes, "max offspring", 6
      @_setProperty allFoxes, "metabolism", 2
    else if allFoxes.length < 16
      @_setProperty allFoxes, "min offspring", 3
      @_setProperty allFoxes, "max offspring", 4
      @_setProperty allFoxes, "metabolism", 3
    else
      @_setProperty allFoxes, "min offspring", 1
      @_setProperty allFoxes, "max offspring", 3
      @_setProperty allFoxes, "metabolism", 4

  preload: [
    "images/agents/grass/tallgrass.png",
    "images/agents/rabbits/rabbit2.png",
    "images/agents/hawks/hawk.png",
    "images/agents/foxes/fox.png"
  ]

window.onload = ->
  helpers.preload [model, env, plantSpecies, rabbitSpecies, hawkSpecies, foxSpecies], ->
    model.run()
    model.setupGraph()
    model.setupPopulationControls()
