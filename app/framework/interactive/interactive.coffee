helpers = require "helpers"
Toolbar = require "interactive/toolbar"
InfoView = require "views/info-view"

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
    if Shutterbug?
      window.shutterbug = new Shutterbug("body")

      # When Shutterbug wants to take a snapshot of the page, it first emits a 'shutterbug-
      # saycheese' event. By default, any WebGL canvas will return a blank image when Shutterbug
      # calls .toDataURL on it, However, if we ask Pixi to render to the canvas during the
      # Shutterbug event loop (remember synthetic events such as 'shutterbug-saycheese' are
      # handled synchronously) the rendered image will still be in the WebGL drawing buffer where
      # Shutterbug can see it.
      $(window).on 'shutterbug-saycheese', =>
        @repaint()


  getEnvironmentPane: ->
    @view = document.createElement 'div'

    @view.setAttribute "style", "height: #{@environment.height}px;"

    @view.appendChild @environment.getView().render()

    @toolbar = new Toolbar(this)
    @view.appendChild @toolbar.getView()

    return @view

  showPlayButton: -> @_opts.playButton
  showResetButton: -> @_opts.resetButton

  repaint: ->
    for view in InfoView.instances()
      view.repaint()
    @environment.getView().repaint()
