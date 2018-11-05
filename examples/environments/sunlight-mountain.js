Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  60
  rows:     52
  imgPath: "images/environments/mountains1.jpg"
  seasonLengths: [30, 30, 20, 5]
  barriers: [
    [  0,   0,  39, 520],
    [561,   0,  39, 520]
  ]
  wrapEastWest: false
  wrapNorthSouth: false

for col in [0..60]
  for row in [0..52]
    env.set col, row, "sunlight", 6

# Health depends on size and sunlight
env.addRule new Rule
  action: (agent) ->
    size     = agent.get 'size'
    sunlight = agent.get 'sunlight'
    diff = Math.abs((11 - size) - sunlight)
    health = 1 - (diff/20.0)
    agent.set 'health', health

# No withered plant can flower
env.addRule new Rule
  action: (agent) ->
    health = agent.get 'health'
    agent.set 'chance of flowering', (if health > 0.99 then 1 else 0)

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

require.register "environments/sunlight-mountain", (exports, require, module) ->
  module.exports = env
