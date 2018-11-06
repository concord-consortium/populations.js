// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.PlusOneSpecies = new Populations.Species({
  speciesName: "plus one",
  agentClass: Populations.Inanimate,
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
