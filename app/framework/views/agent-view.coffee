helpers = require 'helpers'

module.exports = class AgentView

  constructor: ({@agent}) ->

  _images: null
  _sprites: null
  _container: null

  render: (stage, storeForRerender=true) ->
    container = new PIXI.DisplayObjectContainer
    sprites = {}
    # create a texture from set of image paths
    images = @agent.getImages({context: 'environment'})
    for layer in images
      sprite = @_createSprite layer.selectedImage
      sprites[layer.name] = sprite
      container.addChild(sprite)

    container.position.x = @agent._x
    container.position.y = @agent._y

    stage.addChild(container)
    if storeForRerender
      @_rendered = true
      @_container = container
      @_sprites = sprites
      @_images = images

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
        delete @_sprites[name]

    @_container.position.x = @agent._x
    @_container.position.y = @agent._y

  remove: (stage)->
    stage?.removeChild(@_container)

  contains: (x,y)->
    intManager = new PIXI.InteractionManager()
    return intManager.hitTest @_container,
      global:
        x: x
        y: y

  defaultTextViewOptions:
    leaves: true
    roots: true

  textView: (options = {})->
    opts = helpers.setDefaults(options, @defaultTextViewOptions)
    content = document.createElement 'div'

    @_appendPropVals(content, 'Leaf Size:', 'size') if opts.leaves
    @_appendPropVals(content, 'Root Size:', 'size') if opts.roots

    return content

  _appendPropVals: (container, propLabel, propKey)->
    prop = document.createElement 'div'
    prop.classList.add 'agent-property'
    prop.innerHTML = propLabel

    val = document.createElement 'div'
    val.classList.add 'agent-property-value'
    val.innerHTML = @agent.get propKey

    container.appendChild(prop)
    container.appendChild(val)
    return container

  _createSprite: (image)->
    # create a new Sprite using the texture
    texture = PIXI.Texture.fromImage image.path
    sprite = new PIXI.Sprite(texture)
    @_setSpriteProperties(sprite, image)
    return sprite

  _setSpriteProperties: (sprite, image)->
    # default scale of 1 -- same size as the original image
    scale = image.scale || 1
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
