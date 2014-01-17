Agent = require 'models/agent'

describe 'Agent', ->

  it 'should exist', ->
    agent = new Agent name: "myAgent"
    expect(agent).toBeDefined()
    expect(agent.name).toBe("myAgent")
