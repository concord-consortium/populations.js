Environment = require 'models/environment'
Rule        = require 'models/rule'
Trait       = require 'models/trait'
BasicAnimal = require 'models/basic-animal'
FastPlant   = require 'models/fast-plant'

env = new Environment
  columns:  50
  rows:     50
  imgPath: "images/environments/dam-year0.png"
  seasonLengths: [30, 30, 15, 10]
  barriers: [
    [0, 247, 500, 20]
  ]
  wrapEastWest: false
  wrapNorthSouth: false

env.addRule new Rule
  test: (agent)->
    return agent instanceof BasicAnimal && agent.get('prey').length is 0
  action: (agent) ->
    # Set the right prey based on size
    trait = new Trait({name: 'roots', possibleValues: [agent.get('size')]})
    agent.set 'prey', [{name: 'fast plants', traits: [trait]}]

# plants with roots 1
env.addRule new Rule
  test: (agent)->
    return agent instanceof FastPlant && agent.get('roots') is 1
  action: (agent)->
    water = agent.get('water')/10.0
    pop_size_mod = agent.get 'population size modifier'
    pop_size_mod = 0 if (water < 0.8)
    distFrom90 = Math.max(0.9-water, 0.0)
    dryness = Math.min(1.0, distFrom90/0.4)

    # chance of survival is 1.0 at water > 0.9, 0.8 at water < 0.5, and decreases linearly between
    agent.set 'chance of survival', (1 - (dryness * 0.2))
    # growth rate is 0.04 at water > 0.9, 0 at water < 0.5, and decreases linearly between
    agent.set 'growth rate', (0.04 - (dryness * .04) + pop_size_mod)

# plants with roots 2
env.addRule new Rule
  test: (agent)->
    return agent instanceof FastPlant && agent.get('roots') is 2
  action: (agent)->
    water = agent.get('water')/10
    pop_size_mod = agent.get 'population size modifier'
    pop_size_mod = 0 if (water < 0.6)
    distFrom70 = Math.max(0.7-water, 0.0)
    dryness = Math.min(1.0, distFrom70/0.4)

    # chance of survival is 1.0 at water > 0.7, 0.8 at water < 0.3, and decreases linearly between
    agent.set 'chance of survival', (1 - (dryness * 0.2))
    # growth rate is 0.04 at water > 0.7, 0 at water < 0.3, and decreases linearly between
    agent.set 'growth rate', (0.04 - (dryness * .04) + pop_size_mod)

# plants with roots 3
env.addRule new Rule
  test: (agent)->
    return agent instanceof FastPlant && agent.get('roots') is 3
  action: (agent)->
    pop_size_mod = agent.get 'population size modifier'

    # growth rate doesn't depend on the amount of water
    agent.set 'growth rate', (0.04 + pop_size_mod)

require.register "environments/dam", (exports, require, module) ->
  module.exports = env
