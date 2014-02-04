Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  58
  rows:     52
  imgPath: "images/environments/sun5levels.jpg"
  barriers: [
      [0, 0, 95, 520]     # East
      [540, 0, 40, 580]   # West
      [0, 0, 580, 60]     # Top
      [0, 105, 580, 50]   # Rows
      [0, 200, 580, 45]
      [0, 295, 580, 45]
      [0, 390, 580, 40]
      [0, 470, 580, 50]
    ]
  wrapEastWest: true
  wrapNorthSouth: true

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
  test: (agent) ->
    return agent.get('age') > (agent.species.defs.SPROUT_AGE + 4)
  action: (agent) ->
    size     = agent.get 'size'
    sunlight = agent.get 'sunlight'
    diff = Math.abs((11 - size) - sunlight)
    health = 1 - (diff /  20)
    agent.set 'health', health

env.addRule new Rule
  action: (agent)->
    immortal = agent.get('age') < (agent.species.defs.SPROUT_AGE + 10) or agent.get('health') >= 0.87
    agent.set('is immortal', immortal)

env.addRule new Rule
  action: (agent)->
    flowers = agent.get('age') > agent.species.defs.MATURITY_AGE and agent.get('health') >= 0.95
    agent.set('has flowers', flowers)

require.register "environments/sunlight-flowerboxes", (exports, require, module) ->
  module.exports = env