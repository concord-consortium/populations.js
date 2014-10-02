require.register "species/white-brown-rabbits", (exports, require, module) ->

  Species = require 'models/species'
  BasicAnimal = require 'models/agents/basic-animal'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "rabbits"
    agentClass: BasicAnimal
    defs:
      MAX_HEALTH: 1
      MATURITY_AGE: 9
      CHANCE_OF_MUTATION: 0
      INFO_VIEW_SCALE: 2.5
      INFO_VIEW_PROPERTIES:
        "Color: ": 'color'
    traits: [
      new Trait {name: 'speed', default: 30 }
      new Trait {name: 'prey', default: [{name: 'fast plants'}] }
      new Trait {name: 'predator', default: [{name: 'hawks'},{name: 'foxes'}] }
      new Trait {name: 'color', possibleValues: ['white','brown'] }
      new Trait {name: 'vision distance', default: 200 }
      new Trait {name: 'eating distance', default:  50 }
      new Trait {name: 'mating distance', default:  50 }
      new Trait {name: 'max offspring',   default:  6 }
      new Trait {name: 'resource consumption rate', default:  35 }
      new Trait {name: 'metabolism', default:  0.5 }
    ]
    imageRules: [
      {
        name: 'rabbit'
        rules: [
          {
            image:
              path: "images/agents/rabbits/rabbit2.png"
              scale: 0.2
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('color') is 'white'
          }
          {
            image:
              path: "images/agents/rabbits/smallbunny.png"
              scale: 0.2
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('color') is 'brown'
          }
        ]
      }
    ]
