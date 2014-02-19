require.register "species/white-rabbits", (exports, require, module) ->

  Species = require 'models/species'
  BasicAnimal = require 'models/basic-animal'
  FastPlant = require 'models/fast-plant'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "white rabbits"
    agentClass: BasicAnimal
    defs:
      CHANCE_OF_MUTATION: 0
      MATURITY_AGE: 0
    traits: [
      new Trait {name: 'speed', default: 10 }
      new Trait {name: 'prey', default: ['fast plants'] }
      new Trait {name: 'vision distance', default: 100 }
      new Trait {name: 'eating distance', default:  10 }
      new Trait {name: 'mating distance', default: 100 }
      new Trait {name: 'max offspring',   default:  6 }
      new Trait {name: 'resource consumption rate', default:  35 }
      new Trait {name: 'metabolism', default:  2 }
      new Trait {name: 'bubble showing',  possibleValues: ['love', 'food', 'fear', 'none'], default: 'none' }
      new Trait {name: 'is selected',  possibleValues: [true, false], default: false }
      new Trait {name: 'type',  possibleValues: ['slow', 'fast'], default: 'slow' }
    ]
    imageRules: [
      {
        name: 'white rabbit'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/white-rabbits/rabbit-fast.png"
              scale: 0.7
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('current behavior') isnt BasicAnimal.BEHAVIOR.HIDING and agent.get('type') is 'fast'
          }
          {
            image:
              path: "images/agents/white-rabbits/whiteBunny_red.png"
              scale: 0.7
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('current behavior') isnt BasicAnimal.BEHAVIOR.HIDING and agent.get('is selected')
          }
          {
            image:
              path: "images/agents/white-rabbits/rabbit2.png"
              scale: 0.7
              anchor:
                x: 0.8
                y: 0.47
            useIf: (agent)-> agent.get('current behavior') isnt BasicAnimal.BEHAVIOR.HIDING
          }
        ]
      }
      {
        name: 'thought bubble'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/white-rabbits/love-bubble.png"
              scale: 0.7
              anchor:
                x: 0.77
                y: 1
              position:
                y: -16
            useIf: (agent)-> agent.get('bubble showing') is 'love'
          }
          {
            image:
              path: "images/agents/white-rabbits/fear-bubble.png"
              scale: 0.7
              anchor:
                x: 0.77
                y: 1
              position:
                y: -16
            useIf: (agent)-> agent.get('bubble showing') is 'fear'
          }
          {
            image:
              path: "images/agents/white-rabbits/food-bubble.png"
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
