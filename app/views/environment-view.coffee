cursorsClasses = [
  "add-agents"
  "info-tool"
  "carry-tool"
]

module.exports = class EnvironmentView
  showingBarriers: false
  _backgroundSprite: null

  constructor: ({@environment}) ->
    @showingWinter = false
    @_layers = []
    if @environment.winterImgPath?
      @winterImgSprite = new PIXI.TilingSprite PIXI.Texture.fromImage(@environment.winterImgPath), @environment.width, @environment.height
      @winterImgSprite.anchor.x = 0
      @winterImgSprite.anchor.y = 0
      @winterImgSprite.position.x = 0
      @winterImgSprite.position.y = 0

  render: (el) ->
    @stage = new PIXI.Stage(0xFFFFFF, true) unless @stage?
    @renderer = new PIXI.CanvasRenderer(@environment.width, @environment.height)
    # create a texture from an image path
    texture = PIXI.Texture.fromImage @environment.imgPath

    layer = @_getOrCreateLayer 0
    # create a new Sprite using the texture
    @_backgroundSprite = new PIXI.Sprite(texture)

    @_backgroundSprite.anchor.x = 0
    @_backgroundSprite.anchor.y = 0

    @_backgroundSprite.position.x = 0
    @_backgroundSprite.position.y = 0

    layer.addChild(@_backgroundSprite)

    @renderBarriers(layer)

    @renderAgents()

    animate = =>
      requestAnimFrame( animate )
      for agent in @environment.agents

        agent.getView().rerender(@_getOrCreateLayer(agent._viewLayer))

      if @environment.carriedAgent
        @environment.carriedAgent.getView().rerender(@_getOrCreateLayer(100), 'carry-tool')

      @barrierGraphics.visible = @showingBarriers
      @renderer.render(@stage)

    requestAnimFrame( animate )

    @view = @renderer.view

    @addMouseHandlers()

    return @view

  repaint: ->
    @renderer.render @stage

  renderAgents: (stage) ->
    for agent in @environment.agents
      agent.getView().render(@_getOrCreateLayer(agent._viewLayer))

  renderBarriers: (stage) ->
    @barrierGraphics = new PIXI.Graphics()

    @rerenderBarriers()

    stage.addChild(@barrierGraphics)

  rerenderBarriers: ->
    while @barrierGraphics.children.length > 0
      @barrierGraphics.removeChild(@barrierGraphics.children[0])
    @barrierGraphics.clear()

    # set a fill and line style
    @barrierGraphics.beginFill(0xFF3300, 0.5)
    @barrierGraphics.lineStyle(1, 0xffd900, 0.5)

    # draw each barrier
    for b,i in @environment.barriers
      @barrierGraphics.drawRect(b.x1, b.y1, b.x2-b.x1, b.y2-b.y1)
      text = new PIXI.Text(""+i)
      text.position = {x: b.x1+5, y: b.y1+5}
      @barrierGraphics.addChild text

    @barrierGraphics.endFill()
    @barrierGraphics.visible = @showingBarriers

  removeAgent: (agent)->
    agent.getView().remove(@_getOrCreateLayer(agent._viewLayer))

  removeCarriedAgent: (agent)->
    agent.getView().remove(@_getOrCreateLayer(100))

  setCursor: (name) ->
    return unless @view
    for cursorClass in cursorsClasses
      @view.parentElement.classList.remove cursorClass

    @view.parentElement.classList.add name

  addWinterImage: () ->
    @showingWinter = true
    layer = @_getOrCreateLayer(101)
    layer.addChild(@winterImgSprite) unless !@winterImgSprite

  removeWinterImage: () ->
    @showingWinter = false
    layer = @_getOrCreateLayer(101)
    layer.removeChild(@winterImgSprite) unless !@winterImgSprite

  addMouseHandlers: ->
    for eventName in ["click", "mousedown", "mouseup", "mousemove", "touchstart", "touchmove", "touchend"]
      @view.addEventListener eventName,  (evt) =>
        if evt instanceof TouchEvent
          # touch events get their coordinates from a different place
          evt.envX = evt.changedTouches[0].pageX - @view.offsetLeft
          evt.envY = evt.changedTouches[0].pageY - @view.offsetTop
        else
          # use page+offset location, which remain correct after iframe zoom
          evt.envX = evt.pageX - @view.offsetLeft
          evt.envY = evt.pageY - @view.offsetTop
        @environment.send evt.type, evt

  updateBackground: ->
    texture = PIXI.Texture.fromImage @environment.imgPath
    @_backgroundSprite.setTexture texture

  _getOrCreateLayer: (idx)->
    if not @_layers[idx]?
      layer = new PIXI.DisplayObjectContainer
      @_layers[idx] = layer
      if @stage?
        try
          @stage.addChildAt layer, idx
        catch
          @stage.addChild layer
    return @_layers[idx]
