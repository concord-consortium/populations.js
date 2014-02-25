module.exports = class AddOrganismButton

  constructor: (@environment, @toolbar, {@species, @traits, @scatter, @limit, @imagePath}) ->
    if !@scatter
      @toolbar.registerModalButton this

  render: ->
    @button = document.createElement 'div'
    @button.classList.add 'button'
    @button.addEventListener 'click', => @action()
    if !@scatter then @button.classList.add 'modal'

    image = document.createElement 'img'
    image.setAttribute 'src', @imagePath
    @button.appendChild image

    return @button

  getView: -> @button

  _count: 0
  _disabled: false

  disable: ->
    @_disabled = true
    @button.classList.add 'disabled'

  reset: ->
    @_count = 0
    @_disabled = false
    @button.classList.remove 'disabled'

  action: ->
    return if @_disabled
    if @scatter
      @scatterOrganisms()
    else
      @enterAddOrganismsMode()

  scatterOrganisms: ->
    for i in [0...@scatter]
      if @limit and ++@_count >= @limit
        @disable()
        return if @_count > @limit

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
    @environment.setDefaultAgentCreator @species, @traits, =>
      if @limit and ++@_count >= @limit
        @environment.setDefaultAgentCreator null
        @environment.setState @environment.UI_STATE.NONE
        @disable()

    @environment.setState @environment.UI_STATE.ADD_AGENTS
