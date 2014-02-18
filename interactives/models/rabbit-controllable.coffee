helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
Interactive = require 'interactive/interactive'
Events      = require 'events'
ToolButton  = require 'interactive/tool-button'

plantSpecies = require 'species/fast-plants-thin'
# rabbitSpecies = requre 'species/white-rabbit'
env          = require 'environments/grass-field'

window.model =
  setupEnvironment: ->
    for i in [0..21]
      plant = plantSpecies.createAgent()
      plant.set("food quantity",100)
      plant.set("max offspring distance", 200)
      plant.set("min offspring", 1)
      plant.set("max offspring", 2)
      plant.setLocation(@env.randomLocation())
      @env.addAgent(plant)

  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: []
      toolButtons: []

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env
    @plantSpecies = plantSpecies
    # @rabbitSpecies = rabbitSpecies

    @setupEnvironment()

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()

    Events.addEventListener Environment.EVENTS.STEP, =>
      # TODO Track countdown timer, etc.

  showMessage: (message, pause=false) ->
    if pause then @env.stop()
    helpers.showMessage message, @env.getView().view.parentElement, =>
      @env.start()

window.onload = ->
  model.run()
