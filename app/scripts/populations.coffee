Environment = require 'models/environment'
BasicPlant = require 'models/basic-plant'
Rule = require 'models/rule'

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

  rule = new Rule
    test: ->
      return true
    action: (a)->
      loc = a.getLocation()
      a.setLocation(x: loc.x + ExtMath.randomInt(3), y: loc.y + ExtMath.randomInt(3))
      a.getView().rerender()
  env.addRule rule

  envView = env.getView().render()
  document.body.appendChild(envView)

  env.start()
