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

    env.addBarrier 0, 0, 60, 520
    env.addBarrier 0, 0, 580, 40
    env.addBarrier 560, 0, 20, 580

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
             size is 2 and sunlight is 1
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
          image:
            path: "images/agents/varied-plants/seed.png"
            width: 20
            height: 20
          useIf: (agent) -> agent.get('age') < 10
        }
        {
          image:
            path: "images/agents/varied-plants/leaves10.png"
          useIf: (agent) -> agent.get('size') == 0 and agent.get('health') > 0.5
        }
        {
          image:
            path: "images/agents/varied-plants/leaves_wilted10.png"
          useIf: (agent) -> agent.get('size') == 0 and agent.get('health') <= 0.5
        }
        {
          image:
            path: "images/agents/varied-plants/leaves5.png"
          useIf: (agent) -> agent.get('size') == 1 and agent.get('health') > 0.5
        }
        {
          image:
            path: "images/agents/varied-plants/leaves_wilted5.png"
          useIf: (agent) -> agent.get('size') == 1 and agent.get('health') <= 0.5
        }
        {
          image:
            path: "images/agents/varied-plants/leaves1.png"
          useIf: (agent) -> agent.get('size') == 2 and agent.get('health') > 0.5
        }
        {
          image:
            path: "images/agents/varied-plants/leaves_wilted1.png"
          useIf: (agent) -> agent.get('size') == 2 and agent.get('health') <= 0.5
        }
      ]

    envView = env.getView().render()
    document.getElementById('environment').appendChild(envView)

    env.start()

    @env = env
    @plantSpecies = plantSpecies

  plant: ->
    for i in [0...10]
      agent = @plantSpecies.createAgent()
      agent.environment = @env
      agent.setLocation x: ExtMath.randomInt(@env.width), y: ExtMath.randomInt(@env.height)

      while !@env.addAgent(agent)
        agent.setLocation x: ExtMath.randomInt(@env.width), y: ExtMath.randomInt(@env.height)

}
