module.exports = class ToolButton
  @INFO_TOOL: 'info-tool'
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

    for layer in @getButtonImages()
      image = document.createElement 'img'
      image.setAttribute 'src', layer.selectedImage.path
      @button.appendChild image

    return @button

  getView: -> @button

  action: ->
    switch @type
      when ToolButton.INFO_TOOL
        @enterToolMode()
      else
        console.warn("Invalid tool button type: " + @type)

  enterToolMode: ->
    @toolbar.activateModalButton this
    @environment.setState @type

  getButtonImages: ->
    [
      selectedImage:
        path: 'ui/info-tool.png'
    ]

  _getState: ->
    return @_states[@type]

  _states:
    'info-tool':
      enter: ->
        @_view.setCursor "info-tool"
      click: (evt) ->
        agent = @getAgentAt(evt.layerX, evt.layerY)
        return unless agent?
        # TODO Display info pop-up
