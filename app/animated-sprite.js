PIXI.AnimatedSprite = (sequences, firstSequence) ->
  @sequences  = sequences
  unless firstSequence?
    for key of sequences
      @currentSequence = key
      break
  else
    @currentSequence = firstSequence

  @frames = @sequences[@currentSequence].frames
  @frameRate = @sequences[@currentSequence].frameRate || 60
  @loop = @sequences[@currentSequence].loop || false

  PIXI.Sprite.call this, @frames[0]
  @anchor.x = @anchor.y = .5
  @onComplete = null
  @currentFrame = 0
  @previousFrame
  @playing = false
  @loop = false
  return


#animatedSprite
PIXI.AnimatedSprite.constructor = PIXI.AnimatedSprite
PIXI.AnimatedSprite:: = Object.create(PIXI.Sprite::)
PIXI.AnimatedSprite::gotoAndPlay = (where) ->
  if Object::toString.call(where) is "[object String]"
    @currentFrame = 0
    @currentSequence = where
    @frames = @sequences[where].frames
    @frameRate = @sequences[where].frameRate || 60
    @loop = @sequences[where].loop || false
  else
    @frames = @sequences[@currentSequence].frames
    @currentFrame = where
  @playing = true
  return

PIXI.AnimatedSprite::gotoAndStop = (where) ->
  if Object::toString.call(where) is "[object String]"
    @currentFrame = 0
    @currentSequence = where
    @frames = @sequences[where].frames
    @frameRate = @sequences[where].frameRate || 60
    @loop = @sequences[where].loop || false
  else
    @currentFrame = where
  @setTexture @frames[@currentFrame]
  @playing = false
  return

PIXI.AnimatedSprite::play = ->
  @playing = true
  return

PIXI.AnimatedSprite::stop = ->
  @playing = false
  return

PIXI.AnimatedSprite::advanceTime = (dt) ->
  dt = 1 / 60  if typeof dt is "undefined"
  if @playing
    @currentFrame += @frameRate * dt
    constrainedFrame = Math.floor(Math.min(@currentFrame, @frames.length - 1))
    @setTexture @frames[constrainedFrame]
    if @currentFrame >= @frames.length
      if @loop
        @gotoAndPlay 0
      else
        @stop()
      @onComplete @currentSequence  if @onComplete
  return
