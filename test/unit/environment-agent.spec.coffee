###
  Tests describing the interaction between agents, environments, and rules
###

Agent = require 'models/agent'
Environment = require 'models/environment'

describe 'An agent in an environment', ->

  it 'should have access to its cell properties', ->
    env = new Environment
      columns: 5
      rows: 5

    for col in [0..5]
      for row in [0..5]
        env.setCellProperty col, row, "sunlight", row

    agent = new Agent environment: env
    agent.setLocation {x: 0, y: 5}
    expect(agent.getEnvironmentProperty('sunlight')).toEqual 0

    agent.setLocation {x: 0, y: 25}
    expect(agent.getEnvironmentProperty('sunlight')).toEqual 2


