/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/plus-one", function(exports, require, module) {

  const Species = require('models/species');
  const Inanimate = require('models/inanimate');

  return module.exports = new Species({
    speciesName: "plus one",
    agentClass: Inanimate,
    defs: {},
    traits: [],
    imageRules: [
      {
        name: 'plus one',
        contexts: ['environment'],
        rules: [
          {
            image: {
              path: "images/agents/hawks/hawkPlus1.png",
              scale: 0.2,
              anchor: {
                x: 0,
                y: 1
              },
              position: {
                y: -11
              }
            }
          }
        ]
      }
    ]});
});
