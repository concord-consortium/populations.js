module.exports = class InfoView
  constructor: ({@agent})->

  view: null
  setAgent: (@agent)->
    while @_container.children.length > 0
      @_container.removeChild @_container.children[0]
    @agent.getView().render(@_container, 'info-tool')
    @_repositionAgent()

    if @_details.firstChild?
      @_details.replaceChild @agent.getView().textView(), @_details.firstChild
    else
      @_details.appendChild @agent.getView().textView()

  _repositionAgent: ->
    @_container.children[0].position.x = 52
    @_container.children[0].position.y = 70

  _redraw: ->
    if @_showing then requestAnimFrame => @_redraw()
    @_renderer.render @_stage

  render: ->
    @view = document.createElement 'div'
    @view.classList.add 'bubble'

    if @agent._x < @agent.environment.width/2 then @view.classList.add('left') else @view.classList.add('right')
    if @agent._y < @agent.environment.height/2 then @view.classList.add('top') else @view.classList.add('bottom')

    titleBar = document.createElement 'div'
    titleBar.classList.add 'title-bar'

    title = document.createElement 'span'
    title.classList.add 'title'
    title.innerHTML = @agent.label.charAt(0).toUpperCase() + @agent.label.slice(1)

    closeButton = document.createElement 'span'
    closeButton.classList.add 'close'
    closeButton.innerHTML = "<i class='fa fa-times-circle-o'></i>"
    closeButton.addEventListener 'click', =>
      @hide()

    content = document.createElement 'div'
    content.classList.add 'content'

    @_details = document.createElement 'div'
    @_details.classList.add 'details'

    agentView = document.createElement 'div'
    agentView.classList.add 'agent'
    @_stage = new PIXI.Stage(0xFFFFFF, true)
    @_renderer = new PIXI.CanvasRenderer(125, 160)
    @_container = new PIXI.DisplayObjectContainer()
    @_container.scale.x = 1.25
    @_container.scale.y = 1.25
    @_stage.addChild @_container
    @setAgent @agent
    @_redraw()
    agentView.appendChild @_renderer.view

    titleBar.appendChild title
    titleBar.appendChild closeButton

    content.appendChild agentView
    content.appendChild @_details

    @view.appendChild titleBar
    @view.appendChild content

    return @view

  hide: ->
    @view.classList.add 'hidden' unless @view.classList.contains 'hidden'
    @_showing = false

  show: ->
    @view.classList.remove 'hidden'
    @_showing = true
    @_redraw()
