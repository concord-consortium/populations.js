cursorsClasses = [
  "add-agents"
  "info-tool"
]

module.exports = class EnvironmentView

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
    renderer = PIXI.autoDetectRenderer(@environment.width, @environment.height)
    # create a texture from an image path
    texture = PIXI.Texture.fromImage @environment.imgPath
    # create a new Sprite using the texture
    envSprite = new PIXI.Sprite(texture)

    envSprite.anchor.x = 0
    envSprite.anchor.y = 0

    envSprite.position.x = 0
    envSprite.position.y = 0

    @stage.addChild(envSprite)

    @renderAgents(@stage)

    animate = =>
      requestAnimFrame( animate )
      for agent in @environment.agents
        agent.getView().rerender(@stage)
      if @showingWinter
        @stage.swapChildren @winterImgSprite, @stage.children[@stage.children.length-1]
      renderer.render(@stage)

    requestAnimFrame( animate )

    @view = renderer.view

    @addMouseHandlers()

    return @view

  renderAgents: (stage) ->
    for agent in @environment.agents
      agent.getView().render(stage)

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
    @view.addEventListener 'click',  (evt) =>
      @environment.send "click", evt
