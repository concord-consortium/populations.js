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

      env.setCellProperty 0, 0, "sunlight", 0.5

      expect(env.getCellProperty(0, 0, "sunlight")).toBe 0.5


