// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.WhiteBrownRabbitsWithGeneticsSpecies = new Populations.Species({
  speciesName: "rabbits",
  agentClass: Populations.BasicAnimal,
  geneticSpecies: window.WhiteBrownRabbitsGeneticSpecies,
  defs: {
    MAX_AGE: 1000000,
    MAX_HEALTH: 1,
    MATURITY_AGE: 9,
    CHANCE_OF_MATING: 0.03,
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 2.5,
    INFO_VIEW_PROPERTIES: {
      "Color: ": 'color'
    }
  },
  traits: [
    new Populations.Trait({name: 'prey', default: [{name: 'fast plants'}] }),
    new Populations.Trait({name: 'predator', default: [{name: 'hawks'},{name: 'foxes'}] }),
    new Populations.Trait({name: 'color', possibleValues: ['a:B,b:B','a:b,b:B','a:B,b:b','a:b,b:b'], isGenetic: true, isNumeric: false }),
    new Populations.Trait({name: 'vision distance', default: 400 }),
    new Populations.Trait({name: 'eating distance', default:  50 }),
    new Populations.Trait({name: 'mating distance', default:  90 }),
    new Populations.Trait({name: 'max offspring',   default:  6 }),
    new Populations.Trait({name: 'resource consumption rate', default: 1 }),
    new Populations.Trait({name: 'metabolism', default:  0.5 }),
    new Populations.Trait({name: 'wandering threshold', default:  15 })
  ],
  imageProperties: {
    initialFlipDirection: "right"
  },
  imageRules: [
    {
      name: 'rabbit',
      rules: [
        {
          image: {
            path: "images/agents/rabbits/rabbit2.png",
            scale: 0.2,
            anchor: {
              x: 0.8,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('color') === 'white'; }
        },
        {
          image: {
            path: "images/agents/rabbits/smallbunny.png",
            scale: 0.2,
            anchor: {
              x: 0.8,
              y: 0.47
            }
          },
          useIf(agent){ return agent.get('color') === 'brown'; }
        }
      ]
    }
  ]});
