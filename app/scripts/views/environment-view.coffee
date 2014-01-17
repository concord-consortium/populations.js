module.exports = class EnvironmentView

  constructor: ({@width, @height, @imgPath}) ->

  render: (stage) ->
    # create a texture from an image path
    texture = PIXI.Texture.fromImage("/images/environments/sun5levels.jpg")
    # create a new Sprite using the texture
    envSprite = new PIXI.Sprite(texture)

    envSprite.anchor.x = 0
    envSprite.anchor.y = 0

    envSprite.position.x = 0
    envSprite.position.y = 0

    stage.addChild(envSprite)
