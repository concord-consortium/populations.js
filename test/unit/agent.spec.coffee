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

