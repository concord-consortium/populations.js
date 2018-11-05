// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.DrawnRabbitsSpecies = new Populations.Species({
  speciesName: "rabbits",
  agentClass: Populations.BasicAnimal,
  defs: {
    MAX_HEALTH: 1,
    MATURITY_AGE: 9,
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 2.5,
    INFO_VIEW_PROPERTIES: {
      "Color: ": 'color'
    }
  },
  traits: [
    new Populations.Trait({name: 'speed', default: 30 }),
    new Populations.Trait({name: 'prey', default: [{name: 'fast plants'}] }),
    new Populations.Trait({name: 'color', possibleValues: ['white','brown'] }),
    new Populations.Trait({name: 'vision distance', default: 200 }),
    new Populations.Trait({name: 'eating distance', default:  50 }),
    new Populations.Trait({name: 'mating distance', default:  50 }),
    new Populations.Trait({name: 'max offspring',   default:  6 }),
    new Populations.Trait({name: 'resource consumption rate', default:  35 }),
    new Populations.Trait({name: 'metabolism', default:  0.5 }),
    new Populations.Trait({name: "mating desire bonus", default: -20}),
    new Populations.Trait({name: "hunger bonus", default: -10}),
    new Populations.Trait({name: "resource consumption rate", default: 10})
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
            render(g) {
              g.lineStyle(1, 0x000000);
              g.beginFill(0xFFFFFF);
              return g.drawCircle(0,0,10);
            }
          },
          useIf(agent){ return agent.get('color') === 'white'; }
        },
        {
          image: {
            render(g) {
              g.beginFill(0x904f10);
              g.moveTo(0,0);
              g.lineTo(-10, 20);
              return g.lineTo(10, 20);
            }
          },
          useIf(agent){ return agent.get('color') === 'brown'; }
        }
      ]
    }
  ]});