Environment = require 'models/environment'
BasicPlant = require 'models/basic-plant'
require 'helpers'

module.exports = () ->

  # Putting this setup code in here for the moment

  env = new Environment
    columns:  58
    rows:     52
    imgPath: "images/environments/sun5levels.jpg"

  agent = new BasicPlant
    name: "plant1"
    environment: env
    x: ExtMath.randomInt env.width
    y: ExtMath.randomInt env.height

  env.addAgent(agent)

  envView = env.getView().render()
  document.body.appendChild(envView)

  env.start()
