require.register "species/varied-rabbits", (exports, require, module) ->

  Species = require 'models/species'
  BasicAnimal = require 'models/agents/basic-animal'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "rabbits"
    agentClass: BasicAnimal
    defs:
      MAX_HEALTH: 1
      MATURITY_AGE: 10
      CHANCE_OF_MUTATION: 0
      INFO_VIEW_SCALE: 2.5
    traits: [
      new Trait {name: 'speed', default: 30 }
      new Trait {name: 'prey', default: [] }
      new Trait {name: 'predator', default: [{name: 'hawks'},{name: 'foxes'}] }
      new Trait {name: 'vision distance', default: 200 }
      new Trait {name: 'eating distance', default:  50 }
      new Trait {name: 'mating distance', default:  100 }
      new Trait {name: 'max offspring',   default:  6 }
      new Trait {name: 'resource consumption rate', default:  35 }
      new Trait {name: 'metabolism', default:  0.5 }
      new Trait {name: 'bubble showing',  possibleValues: ['love', 'food', 'fear', 'none'], default: 'none' }
      new Trait {name: 'glow',  possibleValues: [true, false], default: false }
      new Trait {name: 'size', possibleValues: [1,2,3]}
    ]
    imageRules: [
      {
        name: 'glow'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/rabbits/smallbunny_glow.png"
              scale: 0.2
              anchor:
                x: 0.75
                y: 0.47
            useIf: (agent)-> agent.get('glow') and agent.get('size') is 1
          }
          {
            image:
              path: "images/agents/rabbits/medbunny_glow.png"
              scale: 0.2
              anchor:
                x: 0.75
                y: 0.47
            useIf: (agent)-> agent.get('glow') and agent.get('size') is 2
          }
          {
            image:
              path: "images/agents/rabbits/bigbunny_glow.png"
              scale: 0.2
              anchor:
                x: 0.75
                y: 0.47
            useIf: (agent)-> agent.get('glow') and agent.get('size') is 3
          }
        ]
      }
      {
        name: 'rabbit'
        rules: [
          {
            image:
              path: "images/agents/rabbits/smallbunny.png"
              scale: 0.2
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('size') is 1
          }
          {
            image:
              path: "images/agents/rabbits/medbunny.png"
              scale: 0.2
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('size') is 2
          }
          {
            image:
              path: "images/agents/rabbits/bigbunny.png"
              scale: 0.2
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('size') is 3
          }
        ]
      }
      {
        name: 'thought bubble'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/rabbits/food-bubble.png"
              scale: 0.7
              anchor:
                x: 0.77
                y: 1
              position:
                y: -16
            useIf: (agent)-> agent.get('bubble showing') is 'food'
          }
        ]
      }
    ]
