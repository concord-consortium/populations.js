helpers = require 'helpers'
require 'animated-sprite'

module.exports = class AgentView

  constructor: ({@agent}) ->
    @imageProperties = @agent.species.imageProperties || {}

  _images: null
  _sprites: null
  _container: null

  render: (stage, context='environment') ->
    container = new PIXI.DisplayObjectContainer
    sprites = {}
    # create a texture from set of image paths
    images = @agent.getImages({context: context})
    for layer in images
      sprite = @_createSprite layer.selectedImage, layer.name
      @_setSpriteProperties(sprite, layer.selectedImage)
      sprites[layer.name] = sprite
      container.addChild(sprite)

    container.position.x = @agent._x
    container.position.y = @agent._y

    stage.addChild(container)

    if context is 'environment' or context is 'carry-tool'
      @_rendered = true
      @_container = container
      @_sprites = sprites
      @_images = images

  rerender: (stage, context='environment') ->
    if !@_rendered
      @render stage, context
      return
    newImages = @agent.getImages({context: context})
    names = []
    # update or create needed sprites
    for layer,i in newImages
      names.push layer.name
      if not @_sprites[layer.name]?
        sprite = @_createSprite layer.selectedImage
        @_sprites[layer.name] = sprite
        @_container.addChildAt(sprite,i)
      else if layer.selectedImage.path? and layer.selectedImage.path != @_sprites[layer.name].texture.baseTexture.source.src
        texture = PIXI.Texture.fromImage layer.selectedImage.path
        sprite = @_sprites[layer.name]
        sprite.setTexture texture
      @_setSpriteProperties(@_sprites[layer.name], layer.selectedImage)

    # remove the no-longer-needed sprites
    for own name,sprite of @_sprites
      if names.indexOf(name) == -1
        @_container.removeChild sprite
        delete @_sprites[name]

    @_container.position.x = @agent._x
    @_container.position.y = @agent._y

    for layer,i in newImages
      if (sprite = @_sprites[layer.name])? and sprite instanceof PIXI.AnimatedSprite
        window.sprite = sprite
        sequence = @agent.getMovement()
        return unless sequence
        if sequence isnt sprite.currentSequence
          if not sprite.playing
            sprite.gotoAndPlay sequence
          else
            sprite.nextSequence = sequence
        sprite.advanceTime()

  remove: (stage)->
    try
      stage?.removeChild(@_container) if @_rendered
    catch e
      console.error("Tried to remove an agent from a stage it wasn't rendered within.")
    @_rendered = false

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

    if @agent.species.defs.INFO_VIEW_PROPERTIES?
      for own k,v of @agent.species.defs.INFO_VIEW_PROPERTIES
        @_appendPropVals(content, k, v)

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

  _createSprite: (image, layerName)->
    # create a new Sprite using the texture
    if not image.animations
      texture = PIXI.Texture.fromImage image.path
      sprite = new PIXI.Sprite(texture)
    else
      sprite = null
      for animation in image.animations
        spriteTextures = []
        for i in [0...animation.length]
          spriteTextures.push PIXI.Texture.fromFrame(animation.animationName+"-"+i)

        if not sprite
          sequences = {}
          sequences[animation.movement]           = {frames: spriteTextures}
          sequences[animation.movement].frameRate = animation.frameRate if animation.frameRate
          sequences[animation.movement].loop      = animation.loop if animation.loop
          sprite = new PIXI.AnimatedSprite sequences
        else
          sprite.sequences[animation.movement]           = {frames: spriteTextures}
          sprite.sequences[animation.movement].frameRate = animation.frameRate if animation.frameRate
          sprite.sequences[animation.movement].loop      = animation.loop if animation.loop

        sprite.nextSequence = null
        sprite.onComplete = (sequence) ->
          if not sprite.sequences[sequence].loop
            if sprite.nextSequence
              sprite.gotoAndPlay sprite.nextSequence
              sprite.nextSequence = null

    return sprite

  _setSpriteProperties: (sprite, image)->
    # default scale of 1 -- same size as the original image
    scale = image.scale || 1
    scale *= @agent.getSize()
    sprite.scale.x = scale
    sprite.scale.y = scale

    if @imageProperties.initialFlipDirection
      d = ExtMath.normalizeRads @agent.get('direction')
      switch @imageProperties.initialFlipDirection
        when "left"
          sprite.scale.x *= -1 if -ExtMath.HALF_PI < d < ExtMath.HALF_PI
        when "right"
          sprite.scale.x *= -1 if -ExtMath.HALF_PI > d || d > ExtMath.HALF_PI
        when "up"
          sprite.scale.y *= -1 if 0 < d < Math.PI
        when "down"
          sprite.scale.y *= -1 if -Math.PI < d < 0

    if @imageProperties.rotate
      initialDirection = @imageProperties.initialRotationDirection || 0
      d = ExtMath.normalizeRads @agent.get('direction')
      dd = d - initialDirection
      sprite.rotation = dd


    # default anchor of 0.5 -- the image is centered on the container's position
    sprite.anchor.x = if image.anchor?.x? then image.anchor.x else 0.5
    sprite.anchor.y = if image.anchor?.y? then image.anchor.y else 0.5

    # default position of 0 -- the image won't be shifted up/down or left/right
    sprite.position.x = if image.position?.x? then image.position.x else 0
    sprite.position.y = if image.position?.y? then image.position.y else 0
    return sprite
