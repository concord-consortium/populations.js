AddOrganismButton = require "interactive/add-organism-button"

module.exports = class Toolbar

  constructor: (interactive) ->
    env = interactive.environment

    @view = document.createElement 'div'
    @view.classList.add "toolbar"
    @view.setAttribute "style", "height: #{env.height}px;"

    if interactive.showPlayButton()
      @addToggleButton "play", (->
          env.start()),
        "pause", (->
          env.stop())
    for opts in interactive.addOrganismButtons
      button = new AddOrganismButton env, opts
      @view.appendChild button.getView()

    if interactive.showResetButton()
      @addButton "reset", ->
        env.reset()

  addButton: (type, action) ->
    button = document.createElement 'div'
    button.classList.add 'button'

    innerButton = document.createElement 'div'
    innerButton.classList.add type
    button.appendChild innerButton

    button.addEventListener 'click', action
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

  getView: ->
    @view