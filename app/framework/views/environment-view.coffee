Toolbar = require "views/toolbar"
cursorsClasses = [
  "add-agents"
]

module.exports = class EnvironmentView

  constructor: ({@environment}) ->

  render: (el) ->
    @stage = new PIXI.Stage(0x66FF99, true) unless @stage?
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
      renderer.render(@stage)

    requestAnimFrame( animate )

    @view = renderer.view

    @addMouseHandlers()

    @toolbar = new Toolbar(@environment)

    el.appendChild(@view)
    el.appendChild(@toolbar.getView())

  renderAgents: (stage) ->
    for agent in @environment.agents
      agent.getView().render(stage)

  setCursor: (name) ->
    for cursorClass in cursorsClasses
      @view.parentElement.classList.remove cursorClass

    @view.parentElement.classList.add name

  addMouseHandlers: ->
    @view.addEventListener 'click',  (evt) =>
      @environment.send "click", evt
