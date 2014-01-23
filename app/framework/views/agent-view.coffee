module.exports = class AgentView

  constructor: ({@agent}) ->

  _image: null

  render: (stage) ->
    # create a texture from an image path
    @_image = @agent.getImage()
    texture = PIXI.Texture.fromImage @_image.path

    # create a new Sprite using the texture
    @_envSprite = new PIXI.Sprite(texture)

    # some random default values for the moment
    @_envSprite.height = @_image.height || 100
    @_envSprite.width = @_image.width || 100

    @_envSprite.anchor.x = @_image.anchor?.x || 0.5
    @_envSprite.anchor.y = @_image.anchor?.y || 0.5

    @_envSprite.position.x = @agent._x
    @_envSprite.position.y = @agent._y

    stage.addChild(@_envSprite)
    @_rendered = true

  rerender: (stage) ->
    if !@_image
      @render stage
      return
    # innefficient first impl
    newImage = @agent.getImage()
    if newImage.path != @_image.path
      @_image = newImage
      texture = PIXI.Texture.fromImage @_image.path
      @_envSprite.setTexture texture
      @_envSprite.height = @_image.height || 100
      @_envSprite.width = @_image.width || 100

      @_envSprite.anchor.x = @_image.anchor?.x || 0.5
      @_envSprite.anchor.y = @_image.anchor?.y || 0.5

    @_envSprite.position.x = @agent._x
    @_envSprite.position.y = @agent._y

  remove: (stage)->
    stage?.removeChild(@_envSprite)
