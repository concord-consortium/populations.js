module.exports = class AgentView

  constructor: ({@agent}) ->

  _imagePath: null

  render: (stage) ->
    # create a texture from an image path
    @_imagePath = @agent.getImagePath()
    texture = PIXI.Texture.fromImage @_imagePath

    # create a new Sprite using the texture
    @_envSprite = new PIXI.Sprite(texture)

    # some random default values for the moment
    @_envSprite.height = 100
    @_envSprite.width = 100

    @_envSprite.anchor.x = 0.5
    @_envSprite.anchor.y = 0.5

    @_envSprite.position.x = @agent._x
    @_envSprite.position.y = @agent._y

    stage.addChild(@_envSprite)

  rerender: (stage) ->
    # innefficient first impl
    newImagePath = @agent.getImagePath()
    if newImagePath != @_imagePath
      @_imagePath = newImagePath
      texture = PIXI.Texture.fromImage @_imagePath
      @_envSprite.setTexture texture

    @_envSprite.position.x = @agent._x
    @_envSprite.position.y = @agent._y
