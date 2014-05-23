helpers = require "helpers"
Toolbar = require "interactive/toolbar"
InfoView = require "interactive/info-view"
SpeedSlider = require "interactive/speed-slider"

defaultOptions =
  environment : null
  playButton  : true
  resetButton : true
  speedSlider : false
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
    if iframePhone?
      phone = iframePhone.getIFrameEndpoint()
      phone.addListener 'stop', =>
        @toolbar.toggleButtons['pause'].click() if @environment._isRunning
      phone.addListener 'start', =>
        @toolbar.toggleButtons['play'].click() unless @environment._isRunning
      phone.addListener 'reset', =>
        @toolbar.toggleButtons['reset'].click()
      phone.initialize()

  getEnvironmentPane: ->
    @view = document.createElement 'div'

    @view.setAttribute "style", "height: #{@environment.height}px;"

    if @_opts.speedSlider
      speedSlider = new SpeedSlider(@environment)
      @view.appendChild speedSlider.getView()

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

window.onerror = (msg, url, line)->
  message = "<div>There was an error in the model!<br/><pre>" + msg + "</pre></div>"
  message += "<div>source: " + url + ", line: " + line + "</div>"
  helpers.showMessage message, document.body
