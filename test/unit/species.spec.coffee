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
          name: 'layer1'
          rules: [
            {
              image:
                path: "no-leaves.png"
              useIf: (agent) -> agent.get('leaves') == 0
            }
            {
              image:
                path: "one-leaf.png"
              useIf: (agent) -> agent.get('leaves') == 1
            }
          ]
        }
      ]

    plant = plantSpecies.createAgent()

    plant.set('leaves', 0)
    expect(plant.getImages()[0].selectedImage.path).toBe "no-leaves.png"

    plant.set('leaves', 1)
    expect(plant.getImages()[0].selectedImage.path).toBe "one-leaf.png"

  it 'can define layered images', ->
    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "leaves", min: 0, max: 1},
        new Trait {name: "flowers", min: 0, max: 2}
      ]
      imageRules: [
        {
          name: 'layer1'
          rules: [
            {
              image:
                path: "no-leaves.png"
              useIf: (agent) -> agent.get('leaves') == 0
            }
            {
              image:
                path: "one-leaf.png"
              useIf: (agent) -> agent.get('leaves') == 1
            }
          ]
        }
        {
          name: 'layer2'
          rules: [
            {
              image:
                path: "no-flowers.png"
              useIf: (agent) -> agent.get('leaves') == 0
            }
            {
              image:
                path: "some-flowers.png"
              useIf: (agent) -> agent.get('leaves') == 1
            }
          ]
        }
      ]

    plant = plantSpecies.createAgent()

    plant.set('leaves', 0)
    plant.set('flowers', 0)
    expect(plant.getImages()[0].selectedImage.path).toBe "no-leaves.png"
    expect(plant.getImages()[1].selectedImage.path).toBe "no-flowers.png"

    plant.set('leaves', 1)
    plant.set('flowers', 1)
    expect(plant.getImages()[0].selectedImage.path).toBe "one-leaf.png"
    expect(plant.getImages()[1].selectedImage.path).toBe "some-flowers.png"

  it 'will not include an image for a layer if none of the images match', ->
    plantSpecies = new Species
      agentClass: Agent
      traits: [
        new Trait {name: "leaves", min: 0, max: 1},
        new Trait {name: "flowers", min: 0, max: 2}
      ]
      imageRules: [
        {
          name: 'layer1'
          rules: [
            {
              image:
                path: "no-leaves.png"
              useIf: (agent) -> agent.get('leaves') == 0
            }
            {
              image:
                path: "one-leaf.png"
              useIf: (agent) -> agent.get('leaves') == 1
            }
          ]
        }
        {
          name: 'layer2'
          rules: [
            {
              image:
                path: "no-flowers.png"
              useIf: (agent) -> agent.get('flowers') == 0
            }
            {
              image:
                path: "some-flowers.png"
              useIf: (agent) -> agent.get('flowers') == 1
            }
          ]
        }
      ]

    plant = plantSpecies.createAgent()

    plant.set('leaves', 0)
    plant.set('flowers', 0)
    expect(plant.getImages()[0].selectedImage.path).toBe "no-leaves.png"
    expect(plant.getImages()[1].selectedImage.path).toBe "no-flowers.png"

    plant.set('leaves', 1)
    plant.set('flowers', 2)
    expect(plant.getImages()[0].selectedImage.path).toBe "one-leaf.png"
    expect(plant.getImages().length).toBe 1


