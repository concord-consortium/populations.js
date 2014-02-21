Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  60
  rows:     70
  imgPath: "images/environments/sun10levels.png"
  winterImgPath: "images/environments/snow-overlay.png"
  seasonLengths: [30, 30, 15, 10]
  barriers: [
      [0, 0, 70, 700]
    ]
  wrapEastWest: false
  wrapNorthSouth: false

for col in [0..60]
  for row in [0..70]
    sunlight = Math.ceil row/7

    env.set col, row, "sunlight", sunlight

# Health depends on size and sunlight
env.addRule new Rule
  action: (agent) ->
    size     = agent.get 'size'
    sunlight = agent.get 'sunlight'
    diff = Math.abs((11 - size) - sunlight)
    healthAtOneUnitDiff = 0.98
    a = 0.2 - 0.25*healthAtOneUnitDiff
    b =1.25*healthAtOneUnitDiff-1.2
    c = 1
    health = Math.max 0, ((a*diff*diff + b*diff + c))
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
