Environment = require 'models/environment'
Rule        = require 'models/rule'

env = new Environment
  columns:  52
  rows:     58
  imgPath: "images/environments/water5levels.png"
  barriers: [
      [  0,   0, 520,  35] # top of the model
      [  0, 465, 520, 115] # bottom of the model
      [  0,  35,  18, 430] # vertical slices between flowerpots
      [100,  35,  18, 430] # vertical slices between flowerpots
      [200,  35,  18, 430] # vertical slices between flowerpots
      [300,  35,  18, 430] # vertical slices between flowerpots
      [400,  35,  18, 430] # vertical slices between flowerpots
      [500,  35,  20, 430] # vertical slices between flowerpots
    ]
  wrapEastWest: true
  wrapNorthSouth: true

for col in [0..(env.columns)]
  for row in [0..(env.rows)]
    water = switch
      when col < 13 then 0.1
      when col < 22 then 0.25
      when col < 32 then 0.5
      when col < 41 then 0.75
      else 1

    env.set col, row, "water", water

env.addRule new Rule
  test: (agent) ->
    return agent.get('age') > (agent.species.defs.SPROUT_AGE + 4)
  action: (agent) ->
    size  = agent.get 'root size'
    water = agent.get 'water'
    diff = Math.abs(size - (water*10))
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

require.register "environments/water-flowerboxes", (exports, require, module) ->
  module.exports = env
