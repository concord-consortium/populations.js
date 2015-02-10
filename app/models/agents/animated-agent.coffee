module.exports = class AnimatedAgent

  @MOVEMENTS:
    STOP: "stop"
    MOVESTEP: "move-step"

  currentMovement: AnimatedAgent.MOVEMENTS.STOPPED

  setMovement: (@currentMovement) ->
    undefined

  getMovement: ->
    @currentMovement
