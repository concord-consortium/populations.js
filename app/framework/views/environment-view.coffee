cursorsClasses = [
  "add-agents"
  "info-tool"
  "carry-tool"
]

module.exports = class EnvironmentView
  showingBarriers: false

  constructor: ({@environment}) ->
    @showingWinter = false
    if @environment.winterImgPath?
      @winterImgSprite = new PIXI.Sprite PIXI.Texture.fromImage @environment.winterImgPath
      @winterImgSprite.anchor.x = 0
      @winterImgSprite.anchor.y = 0
      @winterImgSprite.position.x = 0
      @winterImgSprite.position.y = 0

  render: (el) ->
    @stage = new PIXI.Stage(0xFFFFFF, true) unless @stage?
    @renderer = PIXI.autoDetectRenderer(@environment.width, @environment.height)
    # create a texture from an image path
    texture = PIXI.Texture.fromImage @environment.imgPath
    # create a new Sprite using the texture
    envSprite = new PIXI.Sprite(texture)

    envSprite.anchor.x = 0
    envSprite.anchor.y = 0

    envSprite.position.x = 0
    envSprite.position.y = 0

    @stage.addChild(envSprite)

    @renderBarriers(@stage)

    @renderAgents(@stage)

    animate = =>
      requestAnimFrame( animate )
      for agent in @environment.agents
        agent.getView().rerender(@stage)

      if @environment.carriedAgent
        @environment.carriedAgent.getView().rerender(@stage, 'carry-tool')

      if @showingWinter
        @stage.swapChildren @winterImgSprite, @stage.children[@stage.children.length-1]

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
      agent.getView().render(stage)

  renderBarriers: (stage) ->
    @barrierGraphics = new PIXI.Graphics()

    # set a fill and line style
    @barrierGraphics.beginFill(0xFF3300, 0.5)
    @barrierGraphics.lineStyle(1, 0xffd900, 0.5)

    # draw each barrier
    for b,i in @environment.barriers
      console.log("drawing barrier")
      @barrierGraphics.drawRect(b.x1, b.y1, b.x2-b.x1, b.y2-b.y1)
      text = new PIXI.Text(""+i)
      text.position = {x: b.x1+5, y: b.y1+5}
      @barrierGraphics.addChild text

    @barrierGraphics.endFill()
    @barrierGraphics.visible = @showingBarriers
    stage.addChild(@barrierGraphics)

  setCursor: (name) ->
    for cursorClass in cursorsClasses
      @view.parentElement.classList.remove cursorClass

    @view.parentElement.classList.add name

  addWinterImage: () ->
    @showingWinter = true
    @stage.addChild(@winterImgSprite) unless !@winterImgSprite

  removeWinterImage: () ->
    @showingWinter = false
    @stage.removeChild(@winterImgSprite) unless !@winterImgSprite

  addMouseHandlers: ->
    for eventName in ["click", "mousedown", "mouseup", "mousemove"]
      @view.addEventListener eventName,  (evt) =>
        @environment.send evt.type, evt
