Agent = require 'models/agent'
Environment = require 'models/environment'

describe 'Agent', ->

  it 'should exist', ->
    agent = new Agent name: "myAgent"
    expect(agent).toBeDefined()
    expect(agent.name).toBe("myAgent")

  describe 'Locations', ->

    it 'should have a location when set in the constructor', ->
      agent = new Agent
        x: 0
        y: 1
      expect(agent._x).toBe(0)
      expect(agent._y).toBe(1)
      loc = agent.getLocation()
      expect(loc.x).toBe(0)
      expect(loc.y).toBe(1)

    it 'should not have a location when x is not set in the constructor', ->
      agent = new Agent
        y: 3
      expect(agent._x).not.toBeDefined()
      expect(agent._y).not.toBeDefined()
      loc = agent.getLocation()
      expect(loc.x).not.toBeDefined()
      expect(loc.y).not.toBeDefined()

    it 'should not have a location when y is not set in the constructor', ->
      agent = new Agent
        x: 3
      expect(agent._x).not.toBeDefined()
      expect(agent._y).not.toBeDefined()
      loc = agent.getLocation()
      expect(loc.x).not.toBeDefined()
      expect(loc.y).not.toBeDefined()

    it 'should not have a location when y is not set in the constructor', ->
      agent = new Agent
        name: "myAgent"
      expect(agent._x).not.toBeDefined()
      expect(agent._y).not.toBeDefined()
      loc = agent.getLocation()
      expect(loc.x).not.toBeDefined()
      expect(loc.y).not.toBeDefined()

    describe 'in Environments', ->
      describe 'with no boundary wrapping', ->
        it 'should constrain the x location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          agent = new Agent
            environment: env
            x: 105
            y: 95
          expect(agent._x).toBe(94)
          expect(agent._y).toBe(95)

        it 'should constrain the y location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          agent = new Agent
            environment: env
            x: 85
            y: 115
          expect(agent._x).toBe(85)
          expect(agent._y).toBe(84)

        it 'should constrain the location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          agent = new Agent
            environment: env
            x: 175
            y: 115
          expect(agent._x).toBe(24)
          expect(agent._y).toBe(84)

      describe 'with all boundary wrapping', ->
        it 'should constrain the x location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = true
          agent = new Agent
            environment: env
            x: 105
            y: 95
          expect(agent._x).toBe(5)
          expect(agent._y).toBe(95)

        it 'should constrain the y location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = true
          agent = new Agent
            environment: env
            x: 85
            y: 115
          expect(agent._x).toBe(85)
          expect(agent._y).toBe(15)

        it 'should constrain the location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = true
          agent = new Agent
            environment: env
            x: 175
            y: 115
          expect(agent._x).toBe(75)
          expect(agent._y).toBe(15)

      describe 'with mixed boundary wrapping', ->
        it 'should constrain the x location to the environment size (wrapping)', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = false
          agent = new Agent
            environment: env
            x: 105
            y: 95
          expect(agent._x).toBe( 5)
          expect(agent._y).toBe(95)

        it 'should constrain the x location to the environment size (no wrapping)', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = false
          env.wrapNorthSouth = true
          agent = new Agent
            environment: env
            x: 105
            y: 95
          expect(agent._x).toBe(94)
          expect(agent._y).toBe(95)

        it 'should constrain the y location to the environment size (wrapping)', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = false
          env.wrapNorthSouth = true
          agent = new Agent
            environment: env
            x: 85
            y: 115
          expect(agent._x).toBe(85)
          expect(agent._y).toBe(15)

        it 'should constrain the y location to the environment size (no wrapping)', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = false
          agent = new Agent
            environment: env
            x: 85
            y: 115
          expect(agent._x).toBe(85)
          expect(agent._y).toBe(84)

        it 'should constrain the location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = false
          env.wrapNorthSouth = true
          agent = new Agent
            environment: env
            x: 175
            y: 115
          expect(agent._x).toBe(24)
          expect(agent._y).toBe(15)

        it 'should constrain the location to the environment size', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = false
          agent = new Agent
            environment: env
            x: 175
            y: 115
          expect(agent._x).toBe(75)
          expect(agent._y).toBe(84)

      describe 'with barriers', ->

        it 'should not be able to be placed on a barrier', ->
          env = new Environment
            width: 100
            height: 100

          env.addBarrier 20, 20, 10, 10

          agent1 = new Agent
            environment: env
            x: 5
            y: 5

          retValue = env.addAgent agent1

          expect(retValue).not.toBe false
          expect(env.agents.length).toBe 1

          agent2 = new Agent
            environment: env
            x: 25
            y: 25

          retValue2 = env.addAgent agent2

          expect(retValue2).toBe false
          expect(env.agents.length).toBe 1

        it 'should respect wrapping', ->
          env = new Environment
            width: 100
            height: 100
          env.wrapEastWest = true
          env.wrapNorthSouth = true

          env.addBarrier 20, 20, 10, 10

          agent1 = new Agent
            environment: env
            x: 105
            y: 105

          retValue = env.addAgent agent1

          expect(retValue).not.toBe false
          expect(env.agents.length).toBe 1

          agent2 = new Agent
            environment: env
            x: 125
            y: 125

          retValue2 = env.addAgent agent2

          expect(retValue2).toBe false
          expect(env.agents.length).toBe 1

  describe 'Aging', ->
    it 'should have a default age of 0', ->
      agent = new Agent {}
      expect(agent.get('age')).toBe 0

    it 'should increment age by 1 per step', ->
      agent = new Agent {}
      agent.set('is immortal', true)

      agent.step()
      agent.step()
      expect(agent.get('age')).toBe 2

      agent.step()
      agent.step()
      agent.step()
      expect(agent.get('age')).toBe 5

    it 'should increment agent age when environment.step() is called', ->
      env = new Environment {columns: 5, rows: 5}
      agent = new Agent {x: 0, y: 0}
      agent.set('is immortal', true)
      env.addAgent agent

      env.step()
      env.step()
      env.step()
      expect(agent.get('age')).toBe 3

    it 'should increment agent ages independently', ->
      env = new Environment {columns: 5, rows: 5}
      agent1 = new Agent {x: 0, y: 0}
      agent1.set('is immortal', true)
      agent2 = new Agent {x: 0, y: 0}
      agent2.set('is immortal', true)
      env.addAgent agent1

      env.step()
      env.step()
      env.addAgent agent2
      env.step()
      expect(agent1.get('age')).toBe 3
      expect(agent2.get('age')).toBe 1
