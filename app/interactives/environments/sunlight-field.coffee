Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  58
  rows:     62
  imgPath: "images/environments/sun10levels.png"
  winterImgPath: "images/environments/snow.png"
  seasonLengths: [30, 30, 15, 10]
  barriers: [
      [0, 0, 60, 520]
    ]
  wrapEastWest: true
  wrapNorthSouth: true

for col in [0..58]
  for row in [0..62]
    sunlight = Math.ceil row/6.2

    env.set col, row, "sunlight", sunlight

# Health depends on size and sunlight
env.addRule new Rule
  action: (agent) ->
    size     = agent.get 'size'
    sunlight = agent.get 'sunlight'
    diff = Math.abs((11 - size) - sunlight)
    health = 1 - (diff /  20)
    agent.set 'health', health

# No withered plant can flower
env.addRule new Rule
  test: (agent) ->
    agent.get('health') <= 0.99
  action: (agent) ->
    agent.set 'chance of flowering', 0

# Healthy and withered plants are immortal until fall
env.addRule new Rule
  test: (agent) ->
    season = agent.get 'season'
    agent.get('health') > 0.9 and (season is "spring" or season is "summer")
  action: (agent) ->
    agent.set 'is immortal', true

env.addRule new Rule
  test: (agent) ->
    agent.get('season') is "fall"
  action: (agent) ->
    agent.set 'is immortal', false

require.register "environments/sunlight-field", (exports, require, module) ->
  module.exports = env