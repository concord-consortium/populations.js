module.exports = class Toolbar

  constructor: (env) ->
    @view = document.createElement 'div'
    @view.classList.add "toolbar"
    @view.setAttribute "style", "height: #{env.height}px;"

    @addButton "play", ->
      env.start()

  addButton: (type, action) ->
    button = document.createElement 'div'
    button.classList.add 'button'

    innerButton = document.createElement 'div'
    innerButton.classList.add type
    button.appendChild innerButton
    
    button.addEventListener 'click', action
    @view.appendChild button

  getView: ->
    @view