helpers = require "helpers"
Toolbar = require "interactive/toolbar"

defaultOptions =
  environment : null
  playButton  : true
  resetButton : true
  addOrganismButtons  : []
  toolButtons: []

module.exports = class Interactive

  constructor: (options) ->
    @_opts = helpers.setDefaults(options, defaultOptions)
    @environment = @_opts.environment
    @addOrganismButtons = @_opts.addOrganismButtons
    @toolButtons = @_opts.toolButtons

  getEnvironmentPane: ->
    @view = document.createElement 'div'

    @view.setAttribute "style", "height: #{@environment.height}px;"

    @view.appendChild @environment.getView().render()

    @toolbar = new Toolbar(this)
    @view.appendChild @toolbar.getView()

    return @view

  showPlayButton: -> @_opts.playButton
  showResetButton: -> @_opts.resetButton
