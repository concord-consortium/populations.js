module.exports = class AddOrganismButton

  constructor: (@environment, {@species, @traits, @scatter}) ->

  getView: ->
    button = document.createElement 'div'
    button.classList.add 'button'
    button.addEventListener 'click', => @action()

    for layer in @getButtonImages()
      image = document.createElement 'img'
      image.setAttribute 'src', layer.selectedImage.path
      button.appendChild image

    return button

  action: ->
    if @scatter
      @scatterOrganisms()
    else
      @enterAddOrganismsMode()

  scatterOrganisms: ->
    for i in [0...@scatter]
      agent = @species.createAgent()
      agent.environment = @environment
      agent.setLocation
        x: ExtMath.randomInt(@environment.width)
        y: ExtMath.randomInt(@environment.height)

      while !@environment.addAgent(agent)
        agent.setLocation
          x: ExtMath.randomInt(@environment.width)
          y: ExtMath.randomInt(@environment.height)

  enterAddOrganismsMode: ->
    @environment.setDefaultAgentCreator @species
    @environment.setState @environment.UI_STATE.ADD_AGENTS

  getButtonImages: ->
    dummy = @species.createAgent()
    @species.getImages dummy, {buttonImage: true}