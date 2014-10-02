require.register "species/varied-plants", (exports, require, module) ->

  Species = require 'models/species'
  BasicPlant = require 'models/agents/basic-plant'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "varied plants"
    agentClass: BasicPlant
    defs:
      MAX_AGE: 10000
      MAX_HEALTH: 1
      SPROUT_AGE: 10
      MATURITY_AGE: 25
      CAN_SEED: true
      IS_ANNUAL: true
      CHANCE_OF_SEEDING: 0.6
      CHANCE_OF_MUTATION: 0.2
      INFO_VIEW_PROPERTIES:
        "Leaf Size: ": 'size'
        "Root Size: ": 'root size'
    traits: [
      new Trait {name: "size", min: 1, max: 10, mutatable: true}
      new Trait {name: "root size",min: 1, max: 10, mutatable: true}
    ]
    imageRules: [
      {
        name: 'plant'
        contexts: ['environment','info-tool','carry-tool']
        rules: [
          {
            image:
              path: "images/agents/varied-plants/seed.png"
            useIf: (agent) -> agent.get('age') < @defs.SPROUT_AGE
          }
          {
            image:
              path: "images/agents/varied-plants/leaves10.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 1 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted10.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 1 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves9.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 2 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted9.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 2 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves8.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 3 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted8.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 3 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves7.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 4 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted7.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 4 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves6.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 5 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted6.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 5 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves5.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 6 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted5.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 6 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves4.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 7 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted4.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 7 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves3.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 8 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted3.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 8 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves2.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 9 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted2.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 9 and agent.get('health') <= 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves1.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 10 and agent.get('health') > 0.99
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted1.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 10 and agent.get('health') <= 0.99
          }
        ]
      }
      {
        name: 'roots'
        contexts: ['info-tool','carry-tool']
        rules: [
          {
            image:
              path: "images/agents/varied-plants/roots10.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 10
          }
          {
            image:
              path: "images/agents/varied-plants/roots9.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 9
          }
          {
            image:
              path: "images/agents/varied-plants/roots5.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 5
          }
          {
            image:
              path: "images/agents/varied-plants/roots8.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 8
          }
          {
            image:
              path: "images/agents/varied-plants/roots7.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 7
          }
          {
            image:
              path: "images/agents/varied-plants/roots6.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 6
          }
          {
            image:
              path: "images/agents/varied-plants/roots5.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 5
          }
          {
            image:
              path: "images/agents/varied-plants/roots4.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 4
          }
          {
            image:
              path: "images/agents/varied-plants/roots3.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 3
          }
          {
            image:
              path: "images/agents/varied-plants/roots2.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 2
          }
          {
            image:
              path: "images/agents/varied-plants/roots1.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 0
              position:
                y: -2
            useIf: (agent) -> agent.get('age') >= @defs.SPROUT_AGE and agent.get('root size') == 1
          }
        ]
      }
      {
        name: "flower"
        contexts: ['environment','info-tool','carry-tool']
        rules: [
          {
            image:
              path: "images/agents/varied-plants/flower1.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 10 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower2.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 9 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower3.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 8 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower4.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 7 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower5.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 6 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower6.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 5 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower7.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 4 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower8.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 3 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower9.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 2 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower10.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 1 and agent.get('has flowers')
          }
        ]
      }
    ]
