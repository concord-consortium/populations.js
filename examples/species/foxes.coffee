require.register "species/foxes", (exports, require, module) ->

  Species = require 'models/species'
  BasicAnimal = require 'models/basic-animal'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "foxes"
    agentClass: BasicAnimal
    defs:
      CHANCE_OF_MUTATION: 0
      INFO_VIEW_SCALE: 1
    traits: [
      new Trait {name: 'speed', default: 60 }
      new Trait {name: 'prey', default: [{name: 'rabbits'}] }
      new Trait {name: 'vision distance', default: 300 }
      new Trait {name: 'eating distance', default:  50 }
      new Trait {name: 'mating distance', default:  50 }
      new Trait {name: 'max offspring',   default:  2 }
      new Trait {name: 'resource consumption rate', default:  10 }
      new Trait {name: 'metabolism', default:  0.5 }
    ]
    imageRules: [
      {
        name: 'fox'
        rules: [
          {
            image:
              path: "images/agents/foxes/fox.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0.2
          }
        ]
      }
    ]
