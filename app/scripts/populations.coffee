Environment = require 'models/environment'
BasicPlant = require 'models/basic-plant'
require 'helpers'

module.exports = () ->

  # Putting this setup code in here for the moment

  stage = new PIXI.Stage(0x66FF99)
  renderer = PIXI.autoDetectRenderer(580, 522)
  
  document.body.appendChild(renderer.view)

  env = new Environment
    width:  580
    height: 522
    imgPath: "images/environments/sun5levels.jpg"

  agent = new BasicPlant
    name: "plant1"
    environment: env
    x: ExtMath.randomInt env.width
    y: ExtMath.randomInt env.height

  env.addAgent(agent)

  env.getView().render(stage)

  animate = ->
    requestAnimFrame( animate )
    renderer.render(stage)

  requestAnimFrame( animate )
