Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'

require 'helpers'

module.exports = {

  # Putting this setup code in here for the moment

  run: ->
    env = new Environment
      columns:  58
      rows:     52
      imgPath: "images/environments/sun5levels.jpg"

    env.wrapEastWest = true
    env.wrapNorthSouth = true

    for col in [0..58]
      for row in [0..52]
        sunlight = switch
          when row < 13 then 5
          when row < 22 then 4
          when row < 32 then 3
          when row < 41 then 2
          else 1

        env.set col, row, "sunlight", sunlight

    env.addRule new Rule
        test: (agent) ->
          size     = agent.get 'size'
          sunlight = agent.get 'sunlight'
          if size is 0 and sunlight is 5 or
             size is 1 and sunlight is 3 or
             size is 2 and sunlight is 0
              return false
          return true
        action: (agent) ->
          health = agent.get 'health'
          agent.set 'health', health - 0.03

    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "size", min: 0, max: 2}
        new Trait {name: "health", min: 0, max: 1, default: 1, float: true}
      ]
      imageRules: [
        {
          url: "images/agents/varied-plants/leaves10.png"
          useIf: (agent) -> agent.get('size') == 0 and agent.get('health') > 0.5
        }
        {
          url: "images/agents/varied-plants/leaves_wilted10.png"
          useIf: (agent) -> agent.get('size') == 0 and agent.get('health') <= 0.5
        }
        {
          url: "images/agents/varied-plants/leaves5.png"
          useIf: (agent) -> agent.get('size') == 1 and agent.get('health') > 0.5
        }
        {
          url: "images/agents/varied-plants/leaves_wilted5.png"
          useIf: (agent) -> agent.get('size') == 1 and agent.get('health') <= 0.5
        }
        {
          url: "images/agents/varied-plants/leaves1.png"
          useIf: (agent) -> agent.get('size') == 2 and agent.get('health') > 0.5
        }
        {
          url: "images/agents/varied-plants/leaves_wilted1.png"
          useIf: (agent) -> agent.get('size') == 2 and agent.get('health') <= 0.5
        }
      ]

    for i in [0..30]
      agent = plantSpecies.createAgent()
      agent.environment = env
      agent.setLocation x: ExtMath.randomInt(env.width), y: ExtMath.randomInt(env.height)

      env.addAgent(agent)

    envView = env.getView().render()
    document.body.appendChild(envView)

    env.start()
}
