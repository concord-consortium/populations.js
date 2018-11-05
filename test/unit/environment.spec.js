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

  describe 'can have barriers which', ->
    it 'can detect if a point is inside it', ->
      env = new Environment
        columns: 10
        rows: 10

      env.addBarrier 10, 10, 10, 10

      expect(env.isInBarrier(5,5)).toBe false   # outside
      expect(env.isInBarrier(15,15)).toBe true  # inside
      expect(env.isInBarrier(10,15)).toBe true # left edge
      expect(env.isInBarrier(10,15)).toBe true # right edge
      expect(env.isInBarrier(10,15)).toBe true # top edge
      expect(env.isInBarrier(10,15)).toBe true # bottom edge
      expect(env.isInBarrier(10,10)).toBe true # top-left corner
      expect(env.isInBarrier(20,10)).toBe true # top-right corner
      expect(env.isInBarrier(10,20)).toBe true # bottom-left corner
      expect(env.isInBarrier(20,20)).toBe true # bottom-right corner

    it 'can detect if a line between two points intersects it', ->
      env = new Environment
        columns: 10
        rows: 10

      env.addBarrier 10, 10, 10, 10

      expect(env.crossesBarrier({x: 5, y: 5}, {x: 25, y: 5})).toBe false   # outside above
      expect(env.crossesBarrier({x: 5, y: 5}, {x: 15, y: 15})).toBe true   # ends inside
      expect(env.crossesBarrier({x: 15, y: 5}, {x: 15, y: 25})).toBe true   # ends outside, vertical line
      expect(env.crossesBarrier({x: 10, y: 5}, {x: 10, y: 25})).toBe true   # intersects along an edge, vertical line

      #intersects corner points
      expect(env.crossesBarrier({x: 15, y:  5}, {x:  5, y: 15})).toBe true
      expect(env.crossesBarrier({x: 15, y:  5}, {x: 25, y: 15})).toBe true
      expect(env.crossesBarrier({x:  5, y: 15}, {x: 15, y: 25})).toBe true
      expect(env.crossesBarrier({x: 15, y: 25}, {x: 25, y: 15})).toBe true

      #misses corners
      expect(env.crossesBarrier({x: 15, y:  5}, {x:  5, y: 14})).toBe false
      expect(env.crossesBarrier({x: 15, y:  5}, {x: 25, y: 14})).toBe false
      expect(env.crossesBarrier({x:  5, y: 15}, {x: 15, y: 26})).toBe false
      expect(env.crossesBarrier({x: 15, y: 26}, {x: 25, y: 15})).toBe false

      #slices through corners
      expect(env.crossesBarrier({x: 15, y:  5}, {x:  5, y: 16})).toBe true
      expect(env.crossesBarrier({x: 15, y:  5}, {x: 25, y: 16})).toBe true
      expect(env.crossesBarrier({x:  5, y: 15}, {x: 15, y: 24})).toBe true
      expect(env.crossesBarrier({x: 15, y: 24}, {x: 25, y: 15})).toBe true
