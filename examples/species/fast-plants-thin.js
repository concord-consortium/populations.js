/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/fast-plants-thin", function(exports, require, module) {

  const Species = require('models/species');
  const FastPlant = require('models/fast-plant');
  const Trait   = require('models/trait');

  return module.exports = new Species({
    speciesName: "fast plants",
    agentClass: FastPlant,
    defs: {
      CHANCE_OF_MUTATION: 0,
      MATURITY_AGE: 14
    },
    traits: [
      new Trait({name: "growth rate", min: 0, max: 1, default: 0.0015, float: true, mutatable: false})
    ],
    imageRules: [
      {
        name: 'plant',
        rules: [
          {
            image: {
              path: "images/agents/grass/tallgrass.png",
              scale: 0.35,
              anchor: {
                x: 0.5,
                y: 1
              }
            }
          }
        ]
      }
    ]});
});
