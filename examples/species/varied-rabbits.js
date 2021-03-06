// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.VariedRabbitsSpecies = new Populations.Species({
  speciesName: "rabbits",
  agentClass: Populations.BasicAnimal,
  defs: {
    MAX_HEALTH: 1,
    MATURITY_AGE: 10,
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 2.5
  },
  traits: [
    new Populations.Trait({name: 'speed', default: 30 }),
    new Populations.Trait({name: 'prey', default: [] }),
    new Populations.Trait({name: 'predator', default: [{name: 'hawks'},{name: 'foxes'}] }),
    new Populations.Trait({name: 'vision distance', default: 200 }),
    new Populations.Trait({name: 'eating distance', default:  50 }),
    new Populations.Trait({name: 'mating distance', default:  100 }),
    new Populations.Trait({name: 'max offspring',   default:  6 }),
    new Populations.Trait({name: 'resource consumption rate', default:  35 }),
    new Populations.Trait({name: 'metabolism', default:  0.5 }),
    new Populations.Trait({name: 'bubble showing',  possibleValues: ['love', 'food', 'fear', 'none'], default: 'none' }),
    new Populations.Trait({name: 'glow',  possibleValues: [true, false], default: false }),
    new Populations.Trait({name: 'size', possibleValues: [1,2,3]})
  ],
  imageProperties: {
    initialFlipDirection: "right"
  },
  imageRules: [
    {
      name: 'glow',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/rabbits/smallbunny_glow.png",
            scale: 0.2,
            anchor: {
              x: 0.75,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('glow') && (agent.get('size') === 1); }
        },
        {
          image: {
            path: "images/agents/rabbits/medbunny_glow.png",
            scale: 0.2,
            anchor: {
              x: 0.75,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('glow') && (agent.get('size') === 2); }
        },
        {
          image: {
            path: "images/agents/rabbits/bigbunny_glow.png",
            scale: 0.2,
            anchor: {
              x: 0.75,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('glow') && (agent.get('size') === 3); }
        }
      ]
    },
    {
      name: 'rabbit',
      rules: [
        {
          image: {
            path: "images/agents/rabbits/smallbunny.png",
            scale: 0.2,
            anchor: {
              x: 0.8,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('size') === 1; }
        },
        {
          image: {
            path: "images/agents/rabbits/medbunny.png",
            scale: 0.2,
            anchor: {
              x: 0.8,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('size') === 2; }
        },
        {
          image: {
            path: "images/agents/rabbits/bigbunny.png",
            scale: 0.2,
            anchor: {
              x: 0.8,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('size') === 3; }
        }
      ]
    },
    {
      name: 'thought bubble',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/rabbits/food-bubble.png",
            scale: 0.7,
            anchor: {
              x: 0.77,
              y: 1
            },
            position: {
              y: -16
            }
          },
          useIf(agent){ return agent.get('bubble showing') === 'food'; }
        }
      ]
    }
  ]});
