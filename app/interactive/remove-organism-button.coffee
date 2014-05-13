module.exports = class RemoveOrganismButton

  constructor: (@environment, @toolbar, {@species, @imagePath}) ->

  render: ->
    @button = document.createElement 'div'
    @button.classList.add 'button'
    @button.classList.add 'no-button'
    @button.addEventListener 'click', => @action()

    image = document.createElement 'img'
    image.setAttribute 'src', @imagePath
    @button.appendChild image

    noImage = document.createElement 'img'
    noImage.setAttribute 'src', "ui/no.png"
    @button.appendChild noImage

    return @button

  getView: -> @button

  _disabled: false

  disable: ->
    @_disabled = true
    @button.classList.add 'disabled'

  reset: ->
    @_disabled = false
    @button.classList.remove 'disabled'

  action: ->
    return if @_disabled
    @removeOrganisms()

  removeOrganisms: ->
    for agent in @environment.agents
      if agent.species is @species
        agent.die()
    @environment.removeDeadAgents()
