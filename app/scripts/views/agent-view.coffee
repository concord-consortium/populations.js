module.exports = class AgentView

  constructor: ({@agent}) ->

  render: (stage) ->
    # create a texture from an image path
    texture = PIXI.Texture.fromImage @agent.imgPath
    # create a new Sprite using the texture
    envSprite = new PIXI.Sprite(texture)

    envSprite.anchor.x = 0
    envSprite.anchor.y = 0

    envSprite.position.x = @agent.x
    envSprite.position.y = @agent.y

    stage.addChild(envSprite)
