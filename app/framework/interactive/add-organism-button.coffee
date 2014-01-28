module.exports = class AddOrganismButton

  constructor: (@environment, @toolbar, {@species, @traits, @scatter}) ->
    if !@scatter
      @toolbar.registerModalButton this

  render: ->
    @button = document.createElement 'div'
    @button.classList.add 'button'
    @button.addEventListener 'click', => @action()
    if !@scatter then @button.classList.add 'modal'

    for layer in @getButtonImages()
      image = document.createElement 'img'
      image.setAttribute 'src', layer.selectedImage.path
      @button.appendChild image

    return @button

  getView: -> @button

  action: ->
    if @scatter
      @scatterOrganisms()
    else
      @enterAddOrganismsMode()

  scatterOrganisms: ->
    for i in [0...@scatter]
      agent = @species.createAgent(@traits)
      agent.environment = @environment
      agent.setLocation
        x: ExtMath.randomInt(@environment.width)
        y: ExtMath.randomInt(@environment.height)

      while !@environment.addAgent(agent)
        agent.setLocation
          x: ExtMath.randomInt(@environment.width)
          y: ExtMath.randomInt(@environment.height)

  enterAddOrganismsMode: ->
    @toolbar.activateModalButton this
    @environment.setDefaultAgentCreator @species, @traits
    @environment.setState @environment.UI_STATE.ADD_AGENTS

  getButtonImages: ->
    dummy = @species.createAgent(@traits)
    @species.getImages dummy, {buttonImage: true}