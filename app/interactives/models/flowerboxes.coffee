require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Rule        = require 'models/rule'
Trait       = require 'models/trait'

plantSpecies = require 'species/varied-plants'

window.model = 
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
      action: (agent) ->
        size     = agent.get 'size'
        sunlight = agent.get 'sunlight'
        diff = Math.abs((11 - size) - sunlight)
        health = 1 - (diff /  20)
        agent.set 'health', health

    env.addRule new Rule
      test: (agent)->
        agent.get('age') > 10 and agent.get('health') < 0.87 and agent.get('is immortal')
      action: (agent)->
        agent.set('is immortal', false)

    env.addRule new Rule
      test: (agent)->
        (agent.get('age') < 10 or agent.get('health') >= 0.87) and not agent.get('is immortal')
      action: (agent)->
        agent.set('is immortal', true)

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

window.onload = ->
  model.run()
