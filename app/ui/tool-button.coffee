InfoView = require 'ui/info-view'

module.exports = class ToolButton
  @INFO_TOOL: 'info-tool'
  @CARRY_TOOL: 'carry-tool'
  state: null

  constructor: (@environment, @toolbar, {@type}) ->
    @toolbar.registerModalButton this
    @state = @_getState()
    @environment.addState @type, @state

  render: ->
    @button = document.createElement 'div'
    @button.classList.add 'button'
    @button.addEventListener 'click', => @action()
    @button.classList.add 'modal'

    image = document.createElement 'div'
    image.classList.add @type
    @button.appendChild image

    return @button

  getView: -> @button

  action: ->
    @toolbar.activateModalButton this
    @environment.setState @type

  _getState: ->
    return @_states[@type]

  _states:
    'info-tool':
      enter: ->
        @_view.setCursor "info-tool"
      click: (evt) ->
        # get clicked agent
        agents = @getAgentsAt(evt.envX, evt.envY).filter (a)-> a.canShowInfo()
        return unless agents.length > 0
        agent = agents[0]
        # Display info pop-up for that agent
        if @infoPopup?
          @infoPopup.setAgent(agent)
        else
          @infoPopup = new InfoView({agent})
          document.getElementById('environment').appendChild @infoPopup.render()  # TODO We shouldn't be hard-coding the container...
        for style in ['top','left','bottom','right']
          @infoPopup.view.classList.remove style
        if evt.envX > @width/2
          @infoPopup.view.classList.add 'right'
          @infoPopup.view.style.left = (evt.envX - 225) + "px"
        else
          @infoPopup.view.classList.add 'left'
          @infoPopup.view.style.left = (evt.envX + 35) + "px"
        if evt.envY > @height/2
          @infoPopup.view.classList.add 'bottom'
          @infoPopup.view.style.top = (evt.envY - 162) + "px"
        else
          @infoPopup.view.classList.add 'top'
          @infoPopup.view.style.top = (evt.envY - 25) + "px"
        @infoPopup.show()

    'carry-tool':
      _agent: null
      _origin: null
      _agentOrigin: null
      enter: ->
        @_view.setCursor "carry-tool"
      mousedown: (evt) ->
        agent = @getAgentAt(evt.envX, evt.envY)
        return unless agent?
        @pickUpAgent agent
        @_agent = agent
        @_origin = {x: evt.envX, y: evt.envY}
        @_agentOrigin = agent.getLocation()
      mousemove: (evt) ->
        return unless @_agent?
        dX = evt.envX - @_origin.x
        dY = evt.envY - @_origin.y
        @_agent.setLocation({x: @_agentOrigin.x + dX, y: @_agentOrigin.y + dY})
      mouseup: (evt) ->
        return unless @_agent?
        @dropCarriedAgent()
        @_agent = null
      touchstart: (evt) ->
        evt.preventDefault()
        @send 'mousedown', evt
      touchmove: (evt) ->
        evt.preventDefault()
        @send 'mousemove', evt
      touchend: (evt) ->
        evt.preventDefault()
        @send 'mouseup', evt
