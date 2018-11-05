// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/foxes", function(exports, require, module) {

  const Species = require('models/species');
  const BasicAnimal = require('models/agents/basic-animal');
  const Trait   = require('models/trait');

  return module.exports = new Species({
    speciesName: "foxes",
    agentClass: BasicAnimal,
    defs: {
      CHANCE_OF_MUTATION: 0,
      INFO_VIEW_SCALE: 1
    },
    traits: [
      new Trait({name: 'speed', default: 60 }),
      new Trait({name: 'prey', default: [{name: 'rabbits'}] }),
      new Trait({name: 'vision distance', default: 300 }),
      new Trait({name: 'eating distance', default:  50 }),
      new Trait({name: 'mating distance', default:  50 }),
      new Trait({name: 'max offspring',   default:  2 }),
      new Trait({name: 'resource consumption rate', default:  10 }),
      new Trait({name: 'metabolism', default:  0.5 })
    ],
    imageProperties: {
      initialFlipDirection: "right"
    },
    imageRules: [
      {
        name: 'fox',
        rules: [
          {
            image: {
              path: "images/agents/foxes/fox.png",
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
