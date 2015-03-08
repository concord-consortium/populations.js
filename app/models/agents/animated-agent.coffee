module.exports = class AnimatedAgent

  @MOVEMENTS:
    STOPPED: "stop"
    MOVESTEP: "move-step"

  currentMovement: AnimatedAgent.MOVEMENTS.STOPPED

  setMovement: (@currentMovement) ->
    undefined

  getMovement: ->
    @currentMovement
