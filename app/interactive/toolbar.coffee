AddOrganismButton = require "interactive/add-organism-button"
RemoveOrganismButton = require "interactive/remove-organism-button"
ToolButton  = require 'interactive/tool-button'
Events = require 'events'
Environment = require 'models/environment'

module.exports = class Toolbar

  constructor: (@interactive) ->
    env = @interactive.environment

    @modalButtons = []
    @toggleButtons = []
    @organismButtons = []

    @view = document.createElement 'div'
    @view.classList.add "toolbar"
    @view.setAttribute "style", "height: #{env.height}px;"

    if @interactive.showPlayButton()
      @addToggleButton "play", (->
          env.start()),
        "pause", (->
          env.stop())
      # make sure we keep the button state in sync with the environment state
      Events.addEventListener Environment.EVENTS.PLAY, =>
        @toggleButtons['play'].style.display="none"
        @toggleButtons['pause'].style.display=""
      Events.addEventListener Environment.EVENTS.STOP, =>
        @toggleButtons['play'].style.display=""
        @toggleButtons['pause'].style.display="none"
    for opts in @interactive.addOrganismButtons
      button = new AddOrganismButton env, this, opts
      @view.appendChild button.render()
      @organismButtons.push button

      if opts.showRemoveButton
        removeButton = new RemoveOrganismButton env, this, opts
        @view.appendChild removeButton.render()
        @organismButtons.push removeButton

    for opts in @interactive.toolButtons
      button = new ToolButton env, this, opts
      @view.appendChild button.render()

    if @interactive.showResetButton()
      @addButton "reset", =>
        @reset()
        env.reset()

  addButton: (type, action) ->
    button = document.createElement 'div'
    button.classList.add 'button'

    innerButton = document.createElement 'div'
    innerButton.classList.add type
    button.appendChild innerButton

    button.addEventListener 'click', action
    @toggleButtons[type] = button
    @view.appendChild button

  addToggleButton: (type1, action1, type2, action2) ->
    button1 = @addButton(type1, action1)
    button2 = @addButton(type2, action2)
    button2.style.display="none"

    button1.addEventListener 'click', ->
      button1.style.display="none"
      button2.style.display=""

    button2.addEventListener 'click', ->
      button1.style.display=""
      button2.style.display="none"

  registerModalButton: (btn) ->
    @modalButtons.push btn

  activateModalButton: (btn) ->
    btn.getView().classList.add 'modal-active'
    for button in @modalButtons
      unless button is btn
        button.getView().classList.remove 'modal-active'

  reset: ->
    for button in @modalButtons
      button.getView().classList.remove 'modal-active'
    for button in @organismButtons
      button.reset()
    env = @interactive.environment
    env.setState env.UI_STATE.NONE



  getView: ->
    @view
