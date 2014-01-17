Environment = require 'models/environment'

module.exports = () ->

  # Putting this setup code in here for the moment

  stage = new PIXI.Stage(0x66FF99)
  renderer = PIXI.autoDetectRenderer(580, 522)
  
  document.body.appendChild(renderer.view)

  env = new Environment(400, 300, "/images/environments/sun5levels.jpg")

  env.getView().render(stage)

  animate = ->
    requestAnimFrame( animate )
    renderer.render(stage)

  requestAnimFrame( animate )