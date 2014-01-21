module.exports = class AgentView

  constructor: ({@agent}) ->

  render: (stage) ->
    # create a texture from an image path
    texture = PIXI.Texture.fromImage @agent.imgPath
    # create a new Sprite using the texture
    @_envSprite = new PIXI.Sprite(texture)

    @_envSprite.anchor.x = 0
    @_envSprite.anchor.y = 0

    @_envSprite.position.x = @agent._x
    @_envSprite.position.y = @agent._y

    stage.addChild(@_envSprite)

  rerender: (stage) ->
    @_envSprite.position.x = @agent._x
    @_envSprite.position.y = @agent._y
