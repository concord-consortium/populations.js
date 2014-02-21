Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  70
  rows:     74
  imgPath: "images/environments/water10levels.png"
  winterImgPath: "images/environments/snow-overlay.png"
  seasonLengths: [30, 30, 15, 10]
  barriers: [
    [0, 670, 700, 70]
  ]
  wrapEastWest: false
  wrapNorthSouth: false

for col in [0..(env.columns)]
  water = col/env.columns
  for row in [0..(env.rows)]
    env.set col, row, "water", water

# Health depends on root size and water
env.addRule new Rule
  action: (agent) ->
    size     = agent.get 'root size'
    water    = agent.get 'water'
    diff = Math.abs(size - (water*10))
    healthAtOneUnitDiff = 0.983
    a = 0.2 - 0.25*healthAtOneUnitDiff
    b = 1.25*healthAtOneUnitDiff - 1.2
    c = 1
    h = a*diff*diff + b*diff + c
    h = Math.max(h,0)
    agent.set 'health', h

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

require.register "environments/water-field", (exports, require, module) ->
  module.exports = env
