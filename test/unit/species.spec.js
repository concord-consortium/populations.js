// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Species = require('models/species');
const Agent   = require('models/agent');
const Trait   = require('models/trait');

describe('A species', function() {

  beforeEach(() =>
    jasmine.addMatchers({
      toBeOneOf(util, customEqualityTesters) {
        return {
          compare(actual, expected) {
            return { pass: Array.from(expected).includes(actual), message: `Expected ${actual} to be one of [ ${expected} ]` };
          }
        };
      }}));

  it('can create an agent with specific properties', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", default: 5}),
        new Trait({name: "color", default: "green"})
      ]});

    const plant = plantSpecies.createAgent();

    expect(plant.get("leaves")).toEqual(5);
    return expect(plant.get("color")).toEqual("green");
  });

  it('can create an agent with random properties', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", min: 0, max: 4}),
        new Trait({name: "color", possibleValues: ["green", "red"]}),
        new Trait({name: "random", min: 0, max: 1, float: true})
      ]});

    const plant = plantSpecies.createAgent();

    expect(plant.get("leaves")).toBeGreaterThan(-1);
    expect(plant.get("leaves")).toBeLessThan(5);
    expect(plant.get("color")).toBeOneOf(["green", "red"]);

    const plant2 = plantSpecies.createAgent();

    return expect(plant.get("random")).not.toBe(plant2.get("random"));
  });

  it('can define images to be used for specific traits', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", min: 0, max: 1})
      ],
      imageRules: [
        {
          name: 'layer1',
          rules: [
            {
              image: {
                path: "no-leaves.png"
              },
              useIf(agent) { return agent.get('leaves') === 0; }
            },
            {
              image: {
                path: "one-leaf.png"
              },
              useIf(agent) { return agent.get('leaves') === 1; }
            }
          ]
        }
      ]});

    const plant = plantSpecies.createAgent();

    plant.set('leaves', 0);
    expect(plant.getImages()[0].selectedImage.path).toBe("no-leaves.png");

    plant.set('leaves', 1);
    return expect(plant.getImages()[0].selectedImage.path).toBe("one-leaf.png");
  });

  it('can define images which are always used and do no specify a test', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", min: 0, max: 1})
      ],
      imageRules: [
        {
          name: 'layer1',
          rules: [
            {
              image: {
                path: "one-leaf.png"
              }
            }
          ]
        }
      ]});

    const plant = plantSpecies.createAgent();

    plant.set('leaves', 0);
    expect(plant.getImages()[0].selectedImage.path).toBe("one-leaf.png");

    plant.set('leaves', 1);
    return expect(plant.getImages()[0].selectedImage.path).toBe("one-leaf.png");
  });

  it('can define layered images', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", min: 0, max: 1},
        new Trait({name: "flowers", min: 0, max: 2}))
      ],
      imageRules: [
        {
          name: 'layer1',
          rules: [
            {
              image: {
                path: "no-leaves.png"
              },
              useIf(agent) { return agent.get('leaves') === 0; }
            },
            {
              image: {
                path: "one-leaf.png"
              },
              useIf(agent) { return agent.get('leaves') === 1; }
            }
          ]
        },
        {
          name: 'layer2',
          rules: [
            {
              image: {
                path: "no-flowers.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-flowers.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        }
      ]});

    const plant = plantSpecies.createAgent();

    plant.set('leaves', 0);
    plant.set('flowers', 0);
    expect(plant.getImages()[0].selectedImage.path).toBe("no-leaves.png");
    expect(plant.getImages()[1].selectedImage.path).toBe("no-flowers.png");

    plant.set('leaves', 0);
    plant.set('flowers', 1);
    expect(plant.getImages()[0].selectedImage.path).toBe("no-leaves.png");
    expect(plant.getImages()[1].selectedImage.path).toBe("some-flowers.png");

    plant.set('leaves', 1);
    plant.set('flowers', 0);
    expect(plant.getImages()[0].selectedImage.path).toBe("one-leaf.png");
    return expect(plant.getImages()[1].selectedImage.path).toBe("no-flowers.png");
  });

  it('will not include an image for a layer if none of the images match', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", min: 0, max: 1},
        new Trait({name: "flowers", min: 0, max: 2}))
      ],
      imageRules: [
        {
          name: 'layer1',
          rules: [
            {
              image: {
                path: "no-leaves.png"
              },
              useIf(agent) { return agent.get('leaves') === 0; }
            },
            {
              image: {
                path: "one-leaf.png"
              },
              useIf(agent) { return agent.get('leaves') === 1; }
            }
          ]
        },
        {
          name: 'layer2',
          rules: [
            {
              image: {
                path: "no-flowers.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-flowers.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        }
      ]});

    const plant = plantSpecies.createAgent();

    plant.set('leaves', 0);
    plant.set('flowers', 0);
    expect(plant.getImages()[0].selectedImage.path).toBe("no-leaves.png");
    expect(plant.getImages()[1].selectedImage.path).toBe("no-flowers.png");

    plant.set('leaves', 1);
    plant.set('flowers', 2);
    expect(plant.getImages()[0].selectedImage.path).toBe("one-leaf.png");
    return expect(plant.getImages().length).toBe(1);
  });

  return it('will only include an image for a layer if the context matches', function() {
    const plantSpecies = new Species({
      agentClass: Agent,
      traits: [
        new Trait({name: "leaves", min: 0, max: 1},
        new Trait({name: "flowers", min: 0, max: 2}))
      ],
      imageRules: [
        {
          name: 'layer1',
          contexts: ['info'],
          rules: [
            {
              image: {
                path: "no-layer1.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-layer1.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        },
        {
          name: 'layer2',
          contexts: ['view'],
          rules: [
            {
              image: {
                path: "no-layer2.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-layer2.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        },
        {
          name: 'layer3',
          contexts: ['info','view'],
          rules: [
            {
              image: {
                path: "no-layer3.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-layer3.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        },
        {
          name: 'layer4',
          contexts: [],
          rules: [
            {
              image: {
                path: "no-layer4.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-layer4.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        },
        {
          name: 'layer5',
          rules: [
            {
              image: {
                path: "no-layer5.png"
              },
              useIf(agent) { return agent.get('flowers') === 0; }
            },
            {
              image: {
                path: "some-layer5.png"
              },
              useIf(agent) { return agent.get('flowers') === 1; }
            }
          ]
        }
      ]});

    const plant = plantSpecies.createAgent();
    plant.set('flowers', 0);

    let images = plant.getImages();
    expect(images.length).toBe(5);
    expect(images[0].selectedImage.path).toBe("no-layer1.png");
    expect(images[1].selectedImage.path).toBe("no-layer2.png");
    expect(images[2].selectedImage.path).toBe("no-layer3.png");
    expect(images[3].selectedImage.path).toBe("no-layer4.png");
    expect(images[4].selectedImage.path).toBe("no-layer5.png");

    plant.set('flowers', 1);
    images = plant.getImages({context: 'info'});
    expect(images.length).toBe(4);
    expect(images[0].selectedImage.path).toBe("some-layer1.png");
    expect(images[1].selectedImage.path).toBe("some-layer3.png");
    expect(images[2].selectedImage.path).toBe("some-layer4.png");
    expect(images[3].selectedImage.path).toBe("some-layer5.png");

    images = plant.getImages({context: 'view'});
    expect(images.length).toBe(4);
    expect(images[0].selectedImage.path).toBe("some-layer2.png");
    expect(images[1].selectedImage.path).toBe("some-layer3.png");
    expect(images[2].selectedImage.path).toBe("some-layer4.png");
    return expect(images[3].selectedImage.path).toBe("some-layer5.png");
  });
});



