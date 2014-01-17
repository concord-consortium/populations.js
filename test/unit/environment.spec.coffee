Environment = require 'models/environment'

describe 'An Environment', ->

  it 'can be created with rows and columns', ->
    env = new Environment
      columns: 5
      rows: 6

    expect(env.width).toBe 50
    expect(env.height).toBe 60

  it 'can have its witdth and height changed', ->
    env = new Environment
      columns: 5
      rows: 6

    env.setColumnWidth 1
    env.setRowHeight 2
    expect(env.width).toBe 5
    expect(env.height).toBe 12


