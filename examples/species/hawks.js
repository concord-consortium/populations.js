// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/hawks", function(exports, require, module) {

  const Species = require('models/species');
  const BasicAnimal = require('models/agents/basic-animal');
  const Trait   = require('models/trait');

  return module.exports = new Species({
    speciesName: "hawks",
    agentClass: BasicAnimal,
    defs: {
      CHANCE_OF_MUTATION: 0,
      INFO_VIEW_SCALE: 1
    },
    traits: [
      new Trait({name: 'speed', default: 80 }),
      new Trait({name: 'prey', default: [{name: 'rabbits'}] }),
      new Trait({name: 'vision distance', default: 150 }),
      new Trait({name: 'eating distance', default:  50 }),
      new Trait({name: 'mating distance', default:  50 }),
      new Trait({name: 'max offspring',   default:  3 }),
      new Trait({name: 'resource consumption rate', default:  10 }),
      new Trait({name: 'metabolism', default:  0.5 }),
      new Trait({name: 'wings', default: 0 })
    ],
    viewLayer: 5,
    imageProperties: {
      rotate: true,
      initialRotationDirection: -Math.PI / 2
    },
    imageRules: [
      {
        name: 'hawk',
        rules: [
          {
            image: {
              path: "images/agents/hawks/hawk-small.png",
              scale: 0.2,
              anchor: {
                x: 0.5,
                y: 0.2
              }
            },
            useIf(agent){ return (agent.get('current behavior') === BasicAnimal.BEHAVIOR.EATING) || (agent.get('wings') === 1); }
          },
          {
            image: {
              path: "images/agents/hawks/hawk.png",
              scale: 0.2,
              anchor: {
                x: 0.5,
                y: 0.2
              }
            }
          }
        ]
      }
    ]});
});
