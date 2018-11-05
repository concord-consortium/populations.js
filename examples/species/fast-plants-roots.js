// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.FastPlantsRootsSpecies = new Populations.Species({
  speciesName: "fast plants",
  agentClass: Populations.FastPlant,
  defs: {
    CHANCE_OF_MUTATION: 0,
    MATURITY_AGE: 14,
    INFO_VIEW_SCALE: 2.5
  },
  traits: [
    new Populations.Trait({name: "growth rate", default: 0.0035, float: true }),
    new Populations.Trait({name: "max offspring", default: 3 }),
    new Populations.Trait({name: "max offspring distance", default: 200 }),
    new Populations.Trait({name: "roots", possibleValues: [1,2,3], default: 2 }),
    new Populations.Trait({name: "food quantity", default: 100 })
  ],
  imageRules: [
    {
      name: 'plant',
      rules: [
        {
          image: {
            path: "images/agents/grass/smallgrass.png",
            scale: 0.35,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent){ return (agent.get('roots') === 1) && (agent.get('chance of survival') > 0.999); }
        },
        {
          image: {
            path: "images/agents/grass/smallgrass-brown.png",
            scale: 0.35,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent){ return (agent.get('roots') === 1) && (agent.get('chance of survival') <= 0.999); }
        },
        {
          image: {
            path: "images/agents/grass/medgrass.png",
            scale: 0.35,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent){ return (agent.get('roots') === 2) && (agent.get('chance of survival') > 0.999); }
        },
        {
          image: {
            path: "images/agents/grass/medgrass-brown.png",
            scale: 0.35,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent){ return (agent.get('roots') === 2) && (agent.get('chance of survival') <= 0.999); }
        },
        {
          image: {
            path: "images/agents/grass/tallgrass.png",
            scale: 0.35,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent){ return (agent.get('roots') === 3) && (agent.get('chance of survival') > 0.999); }
        },
        {
          image: {
            path: "images/agents/grass/tallgrass-brown.png",
            scale: 0.35,
            anchor: {
              x: 0.5,
              y: 1
            }
          },
          useIf(agent){ return (agent.get('roots') === 3) && (agent.get('chance of survival') <= 0.999); }
        }
      ]
    }
  ]});
