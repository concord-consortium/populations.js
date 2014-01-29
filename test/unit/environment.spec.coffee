Environment = require 'models/environment'

describe 'An Environment', ->

  it 'can be created with rows and columns', ->
    env = new Environment
      columns: 5
      rows: 6

    expect(env.width).toBe 50
    expect(env.height).toBe 60

  it 'can be created with width and height', ->
    env = new Environment
      width: 50
      height: 60

    expect(env.columns).toBe 5
    expect(env.rows).toBe 6

  describe 'has Cells which', ->

    it 'have properties that can be set and read', ->
      env = new Environment
        columns: 5
        rows: 5

      env.set 0, 0, "sunlight", 0.5

      expect(env.get(0, 0, "sunlight")).toBe 0.5

  describe 'can have seasons which', ->

    # this allows rules like agent.get("season") as well
    it 'can be accessed by env.get()', ->
      env = new Environment
        columns: 5
        rows: 5

      expect(env.get(0, 0, "season")).toBe "spring"

    it 'can have defined lengths', ->
      env = new Environment
        columns: 5
        rows: 5
        seasonLengths: [5, 20, 5, 3]

      expect(env.get(0, 0, "yearLength")).toBe 33

      env.step() for i in [0...4]
      expect(env.get(0, 0, "season")).toBe "spring"

      env.step() for i in [0...20]
      expect(env.get(0, 0, "season")).toBe "summer"

      env.step() for i in [0...5]
      expect(env.get(0, 0, "season")).toBe "fall"

      env.step() for i in [0...3]
      expect(env.get(0, 0, "season")).toBe "winter"

      env.step() for i in [0...3]
      expect(env.get(0, 0, "season")).toBe "spring"


