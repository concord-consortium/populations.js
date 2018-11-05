/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/white-brown-rabbits-genetics", function(exports, require, module) {

  const Species = require('models/species');
  const BasicAnimal = require('models/agents/basic-animal');
  const Trait   = require('models/trait');

  const biologicaSpecies = require('species/biologica/white-brown-rabbits');

  return module.exports = new Species({
    speciesName: "rabbits",
    agentClass: BasicAnimal,
    geneticSpecies: biologicaSpecies,
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
      new Trait({name: 'prey', default: [{name: 'fast plants'}] }),
      new Trait({name: 'predator', default: [{name: 'hawks'},{name: 'foxes'}] }),
      new Trait({name: 'color', possibleValues: ['a:B,b:B','a:b,b:B','a:B,b:b','a:b,b:b'], isGenetic: true, isNumeric: false }),
      new Trait({name: 'vision distance', default: 400 }),
      new Trait({name: 'eating distance', default:  50 }),
      new Trait({name: 'mating distance', default:  90 }),
      new Trait({name: 'max offspring',   default:  6 }),
      new Trait({name: 'resource consumption rate', default: 1 }),
      new Trait({name: 'metabolism', default:  0.5 }),
      new Trait({name: 'wandering threshold', default:  15 })
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
});
