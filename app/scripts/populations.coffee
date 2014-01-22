Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'

require 'helpers'

module.exports = () ->

  # Putting this setup code in here for the moment

  env = new Environment
    columns:  58
    rows:     52
    imgPath: "images/environments/sun5levels.jpg"

  env.wrapEastWest = true
  env.wrapNorthSouth = true

  plantSpecies = new Species
    agentClass: Agent
    traits: [
      new Trait {name: "size", min: 0, max: 2}
    ]
    imageRules: [
      {
        url: "images/agents/varied-plants/leaves10.png"
        useIf: (agent) -> agent.get('size') == 0
      }
      {
        url: "images/agents/varied-plants/leaves5.png"
        useIf: (agent) -> agent.get('size') == 1
      }
      {
        url: "images/agents/varied-plants/leaves1.png"
        useIf: (agent) -> agent.get('size') == 2
      }
    ]

  for i in [0..10]
    agent = plantSpecies.createAgent()
    agent.environment = env
    agent.setLocation x: ExtMath.randomInt(env.width), y: ExtMath.randomInt(env.height)

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
