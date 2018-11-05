PPSlider    = require 'ui/ppslider'

module.exports = class SpeedSlider

  constructor: (env) ->
    @view = document.createElement 'div'
    @view.setAttribute "style", "height: 20px;"

    input = document.createElement 'input'

    input.setAttribute "id", "speed-slider"
    input.setAttribute "type", 'hidden'
    input.setAttribute "value", 50

    @view.appendChild input

    # TODO Remove jQuery once we're no longer relying on it.
    $( document ).ready ->
      $(input).change ->
        env.setSpeed(parseInt($(@).val()))

      $(input).PPSlider({width: env.width})

  getView: -> @view


