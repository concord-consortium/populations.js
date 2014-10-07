helpers     = require 'helpers'

Interactive = require 'ui/interactive'
ToolButton  = require 'ui/tool-button'

foxSpecies  = require 'species/animated-foxes'
env         = require 'environments/open'

window.model =
  run: ->
    @interactive = new Interactive
      environment: env
      speedSlider: false
      addOrganismButtons: [
        {
          species: foxSpecies
          scatter: 1
          imagePath: "images/agents/foxes/fox.png"
        }
      ]
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

window.onload = ->
  helpers.preload [model, env, foxSpecies], ->
    model.run()
