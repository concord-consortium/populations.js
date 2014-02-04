InfoView = require 'interactive/info-view'

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

    image = document.createElement 'img'
    image.setAttribute 'src', @_getButtonImage()
    @button.appendChild image

    return @button

  getView: -> @button

  action: ->
    @toolbar.activateModalButton this
    @environment.setState @type

  _getButtonImage: ->
    switch @type
      when 'info-tool'  then 'ui/info-tool.png'
      when 'carry-tool' then 'ui/carry-plant.png'

  _getState: ->
    return @_states[@type]

  _states:
    'info-tool':
      enter: ->
        @_view.setCursor "info-tool"
      click: (evt) ->
        # get clicked agent
        agent = @getAgentAt(evt.layerX, evt.layerY)
        return unless agent?
        # Display info pop-up for that agent
        if @infoPopup?
          @infoPopup.setAgent(agent)
        else
          @infoPopup = new InfoView({agent})
          document.getElementById('environment').appendChild @infoPopup.render()  # TODO We shouldn't be hard-coding the container...
        for style in ['top','left','bottom','right']
          @infoPopup.view.classList.remove style
        if evt.layerX > @width/2
          @infoPopup.view.classList.add 'right'
          @infoPopup.view.style.left = (evt.layerX - 225) + "px"
        else
          @infoPopup.view.classList.add 'left'
          @infoPopup.view.style.left = (evt.layerX + 35) + "px"
        if evt.layerY > @height/2
          @infoPopup.view.classList.add 'bottom'
          @infoPopup.view.style.top = (evt.layerY - 162) + "px"
        else
          @infoPopup.view.classList.add 'top'
          @infoPopup.view.style.top = (evt.layerY - 25) + "px"
        @infoPopup.show()

    'carry-tool':
      _agent: null
      _origin: null
      _agentOrigin: null
      enter: ->
        @_view.setCursor "carry-tool"
      mousedown: (evt) ->
        agent = @getAgentAt(evt.layerX, evt.layerY)
        return unless agent?
        @pickUpAgent agent
        @_agent = agent
        @_origin = {x: evt.layerX, y: evt.layerY}
        @_agentOrigin = agent.getLocation()
      mousemove: (evt) ->
        return unless @_agent?
        dX = evt.layerX - @_origin.x
        dY = evt.layerY - @_origin.y
        @_agent.setLocation({x: @_agentOrigin.x + dX, y: @_agentOrigin.y + dY})
      mouseup: (evt) ->
        return unless @_agent?
        @dropCarriedAgent()
        @_agent = null