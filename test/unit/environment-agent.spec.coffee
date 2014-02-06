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
        env.set col, row, "sunlight", row

    agent = new Agent environment: env
    agent.setLocation {x: 0, y: 5}
    expect(agent.getEnvironmentProperty('sunlight')).toEqual 0

    agent.setLocation {x: 0, y: 25}
    expect(agent.getEnvironmentProperty('sunlight')).toEqual 2

    describe 'with rules', ->

      it 'should run the rules correctly', ->

        env = new Environment
          columns: 5
          rows: 5

        for col in [0..5]
          for row in [0..5]
            env.set col, row, "sunlight", row

        env.addRule new Rule
            test: (agent) ->
              return agent.getEnvironmentProperty('sunlight') >= 2
            action: (agent) ->
              agent.set 'health', 1

        env.addRule new Rule
            test: (agent) ->
              return agent.getEnvironmentProperty('sunlight') < 2
            action: (agent) ->
              agent.set 'health', 0

        agent = new Agent {}
        agent.set('is immortal', true)
        agent.setLocation {x: 0, y: 35}     # sunlight = 3
        env.addAgent(agent)

        env.step()

        expect(agent.get 'health').toEqual 1

        agent.setLocation {x: 0, y: 15}     # sunlight = 0
        env.step()

        expect(agent.get 'health').toEqual 0

