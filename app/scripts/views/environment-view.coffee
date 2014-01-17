module.exports = class EnvironmentView

  constructor: ({@environment}) ->

  render: (stage) ->
    stage = new PIXI.Stage(0x66FF99)
    renderer = PIXI.autoDetectRenderer(@environment.width, @environment.height)
    # create a texture from an image path
    texture = PIXI.Texture.fromImage @environment.imgPath
    # create a new Sprite using the texture
    envSprite = new PIXI.Sprite(texture)

    envSprite.anchor.x = 0
    envSprite.anchor.y = 0

    envSprite.position.x = 0
    envSprite.position.y = 0

    stage.addChild(envSprite)

    @renderAgents(stage)

    animate = ->
      requestAnimFrame( animate )
      renderer.render(stage)

    requestAnimFrame( animate )

    return renderer.view

  renderAgents: (stage) ->
    for agent in @environment.agents
      agent.getView().render(stage)
