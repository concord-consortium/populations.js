// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.MiceSpecies = new Populations.Species({
  speciesName: "mice",
  agentClass: Populations.BasicAnimal,
  defs: {
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 1
  },
  traits: [
    new Populations.Trait({name: 'speed', default: 60 }),
    new Populations.Trait({name: 'prey', default: [{name: 'rabbits'}] }),
    new Populations.Trait({name: 'vision distance', default: 300 }),
    new Populations.Trait({name: 'eating distance', default:  50 }),
    new Populations.Trait({name: 'mating distance', default:  50 }),
    new Populations.Trait({name: 'max offspring',   default:  2 }),
    new Populations.Trait({name: 'resource consumption rate', default:  10 }),
    new Populations.Trait({name: 'metabolism', default:  0.5 })
  ],
  imageProperties: {
    initialFlipDirection: "right"
  },
  imageRules: [
    {
      name: 'mouse',
      rules: [
        {
          image: {
            path: "images/agents/mouse/mouse.png",
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
