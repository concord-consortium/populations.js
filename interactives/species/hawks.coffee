require.register "species/hawks", (exports, require, module) ->

  Species = require 'models/species'
  BasicAnimal = require 'models/basic-animal'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "hawks"
    agentClass: BasicAnimal
    defs:
      CHANCE_OF_MUTATION: 0
    traits: [
      new Trait {name: 'speed', default: 8 }
      new Trait {name: 'prey', default: ['rabbits'] }
      new Trait {name: 'color', possibleValues: ['white','brown'] }
      new Trait {name: 'vision distance', default: 150 }
      new Trait {name: 'eating distance', default:  50 }
      new Trait {name: 'mating distance', default: 100 }
      new Trait {name: 'max offspring',   default:  3 }
      new Trait {name: 'resource consumption rate', default:  35 }
      new Trait {name: 'metabolism', default:  0.5 }
      new Trait {name: 'wings', default: 0 }
    ]
    imageRules: [
      {
        name: 'hawk'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/hawks/hawk-small.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0.2
            useIf: (agent)-> agent.get('current behavior') is BasicAnimal.BEHAVIOR.EATING or agent.get('wings') is 1
          }
          {
            image:
              path: "images/agents/hawks/hawk.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0.2
          }
        ]
      }
    ]
