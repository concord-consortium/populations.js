Species = require 'models/species'
Agent   = require 'models/agent'
Trait   = require 'models/trait'

describe 'A species', ->

  beforeEach ->
    @addMatchers
      toBeOneOf: (arr) ->
        arr.indexOf(this.actual) != -1

  it 'can create an agent with specific properties', ->
    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "leaves", default: 5}
        new Trait {name: "color", default: "green"}
      ]

    plant = plantSpecies.createAgent()

    expect(plant.props["leaves"]).toEqual 5
    expect(plant.props["color"]).toEqual "green"

  it 'can create an agent with random properties', ->
    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "leaves", min: 0, max: 4}
        new Trait {name: "color", possibleValues: ["green", "red"]}
        new Trait {name: "random", min: 0, max: 1, float: true}
      ]

    plant = plantSpecies.createAgent()

    expect(plant.props["leaves"]).toBeGreaterThan -1
    expect(plant.props["leaves"]).toBeLessThan 5
    expect(plant.props["color"]).toBeOneOf ["green", "red"]

    plant2 = plantSpecies.createAgent()

    expect(plant.props["random"]).not.toBe plant2.props["random"]

