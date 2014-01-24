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
          when row < 13 then 10
          when row < 22 then 8
          when row < 32 then 6
          when row < 41 then 4
          else 2

        env.set col, row, "sunlight", sunlight

    env.addRule new Rule
      action: (agent) ->
        size     = agent.get 'size'
        sunlight = agent.get 'sunlight'
        diff = Math.abs((11 - size) - sunlight)
        health = 1 - (diff /  20)
        agent.set 'health', health

    env.addRule new Rule
      action: (agent)->
        immortal = agent.get('age') < 10 or agent.get('health') >= 0.87
        agent.set('is immortal', immortal)

    env.addRule new Rule
      action: (agent)->
        flowers = agent.get('age') > 20 and agent.get('health') >= 0.95
        agent.set('has flowers', flowers)

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
