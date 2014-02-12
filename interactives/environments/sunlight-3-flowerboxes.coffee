Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  58
  rows:     49
  imgPath: "images/environments/sun3levels.png"
  seasonLengths: [30, 30, 15, 10]
  barriers: [
      [0, 0, 95, 490]     # East
      [545, 0, 40, 490]   # West
      [0, 0, 580, 65]     # Top
      [0, 130, 580, 70]   # Rows
      [0, 260, 580, 70]
      [0, 400, 580, 90]
    ]
  wrapEastWest: false
  wrapNorthSouth: false

for col in [0..58]
  for row in [0..49]
    sunlight = switch
      when row < 15 then 7
      when row < 30 then 6
      else 5

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
    flowers = agent.get('age') > agent.species.defs.MATURITY_AGE and agent.get('health') >= 0.99
    agent.set('has flowers', flowers)

require.register "environments/sunlight-3-flowerboxes", (exports, require, module) ->
  module.exports = env
