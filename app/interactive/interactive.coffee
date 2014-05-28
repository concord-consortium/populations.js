helpers = require "helpers"
Toolbar = require "interactive/toolbar"
InfoView = require "interactive/info-view"
SpeedSlider = require "interactive/speed-slider"
Events = require 'events'
Environment = require 'models/environment'

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
      ignoreEvent = false
      phone.addListener 'stop', =>
        ignoreEvent = true
        @toolbar.toggleButtons['pause'].click() if @environment._isRunning
        ignoreEvent = false
      phone.addListener 'play', =>
        ignoreEvent = true
        @toolbar.toggleButtons['play'].click() unless @environment._isRunning
        ignoreEvent = false
      phone.addListener 'reset', =>
        ignoreEvent = true
        @toolbar.toggleButtons['reset'].click()
        ignoreEvent = false
      Events.addEventListener Environment.EVENTS.PLAY, =>
        phone.post({type: 'play'}) unless ignoreEvent
      Events.addEventListener Environment.EVENTS.STOP, =>
        phone.post({type: 'stop'}) unless ignoreEvent
      Events.addEventListener Environment.EVENTS.RESET, =>
        phone.post({type: 'reset'}) unless ignoreEvent
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
