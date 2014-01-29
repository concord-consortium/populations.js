module.exports = class AgentView

  constructor: ({@agent}) ->

  _images: null
  _sprites: null
  _container: null

  render: (stage) ->
    @_container = new PIXI.DisplayObjectContainer
    @_sprites = {}
    # create a texture from set of image paths
    @_images = @agent.getImages({context: 'environment'})
    for layer in @_images
      sprite = @_createSprite layer.selectedImage
      @_sprites[layer.name] = sprite
      @_container.addChild(sprite)

    @_container.position.x = @agent._x
    @_container.position.y = @agent._y

    stage.addChild(@_container)
    @_rendered = true

  rerender: (stage) ->
    if !@_images
      @render stage
      return
    newImages = @agent.getImages({context: 'environment'})
    names = []
    # update or create needed sprites
    for layer,i in newImages
      names.push layer.name
      if not @_sprites[layer.name]?
        sprite = @_createSprite layer.selectedImage
        @_sprites[layer.name] = sprite
        @_container.addChildAt(sprite,i)
      else if layer.selectedImage.path != @_sprites[layer.name].texture.baseTexture.source.src
        texture = PIXI.Texture.fromImage layer.selectedImage.path
        sprite = @_sprites[layer.name]
        sprite.setTexture texture
        @_setSpriteProperties(sprite, layer.selectedImage)

    # remove the no-longer-needed sprites
    for own name,sprite of @_sprites
      if names.indexOf(name) == -1
        @_container.removeChild sprite
        @_sprites[name] = null

    @_container.position.x = @agent._x
    @_container.position.y = @agent._y

  remove: (stage)->
    stage?.removeChild(@_container)

  _createSprite: (image)->
    # create a new Sprite using the texture
    texture = PIXI.Texture.fromImage image.path
    sprite = new PIXI.Sprite(texture)
    @_setSpriteProperties(sprite, image)
    return sprite

  _setSpriteProperties: (sprite, image)->
    # default scale of 1 -- same size as the original image
    scale = image.scale || 1
    console.log @agent.getSize()
    scale *= @agent.getSize()
    sprite.scale.x = scale
    sprite.scale.y = scale

    # default anchor of 0.5 -- the image is centered on the container's position
    sprite.anchor.x = image.anchor?.x || 0.5
    sprite.anchor.y = image.anchor?.y || 0.5

    # default position of 0 -- the image won't be shifted up/down or left/right
    sprite.position.x = image.position?.x || 0
    sprite.position.y = image.position?.y || 0
    return sprite
