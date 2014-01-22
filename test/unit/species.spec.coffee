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

    expect(plant.get("leaves")).toEqual 5
    expect(plant.get("color")).toEqual "green"

  it 'can create an agent with random properties', ->
    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "leaves", min: 0, max: 4}
        new Trait {name: "color", possibleValues: ["green", "red"]}
        new Trait {name: "random", min: 0, max: 1, float: true}
      ]

    plant = plantSpecies.createAgent()

    expect(plant.get("leaves")).toBeGreaterThan -1
    expect(plant.get("leaves")).toBeLessThan 5
    expect(plant.get("color")).toBeOneOf ["green", "red"]

    plant2 = plantSpecies.createAgent()

    expect(plant.get("random")).not.toBe plant2.get("random")

  it 'can define images to be used for specific traits', ->
    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "leaves", min: 0, max: 1}
      ]
      imageRules: [
        {
          url: "no-leaves.png"
          useIf: (agent) -> agent.get('leaves') == 0
        }
        {
          url: "one-leaf.png"
          useIf: (agent) -> agent.get('leaves') == 1
        }
      ]

    plant = plantSpecies.createAgent()

    plant.set('leaves', 0)
    expect(plant.getImagePath()).toBe "no-leaves.png"

    plant.set('leaves', 1)
    expect(plant.getImagePath()).toBe "one-leaf.png"


