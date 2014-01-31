require.register "species/varied-plants", (exports, require, module) ->

  Species = require 'models/species'
  BasicPlant = require 'models/basic-plant'
  Trait   = require 'models/trait'

  module.exports = new Species
    agentClass: BasicPlant
    defs:
      SPROUT_AGE: 10
      MATURITY_AGE: 25
      CAN_SEED: true
      IS_ANNUAL: true
      CHANCE_OF_FLOWERING: 0.2
      CHANCE_OF_SEEDING: 0.6
    traits: [
      new Trait {name: "size", possibleValues: [1, 5, 10]}
      new Trait {name: "health", min: 0, max: 1, default: 1, float: true}
    ]
    imageRules: [
      {
        name: 'plant'
        contexts: ['environment','info-tool']
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
            useIf: (agent) -> agent.get('size') == 1 and agent.get('health') > 0.85
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted10.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 1 and agent.get('health') <= 0.85
          }
          {
            image:
              path: "images/agents/varied-plants/leaves5.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 5 and agent.get('health') > 0.85
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted5.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 5 and agent.get('health') <= 0.85
          }
          {
            image:
              path: "images/agents/varied-plants/leaves1.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 10 and agent.get('health') > 0.85
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted1.png"
              scale: 0.2
              anchor:
                x: 0.5
                y: 1
            useIf: (agent) -> agent.get('size') == 10 and agent.get('health') <= 0.85
          }
        ]
      }
      {
        name: "flower"
        contexts: ['environment','info-tool']
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
              path: "images/agents/varied-plants/flower4.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 5 and agent.get('has flowers')
          }
          {
            image:
              path: "images/agents/varied-plants/flower9.png"
              scale: 0.2
              position:
                x: -3
                y: -51
            useIf: (agent) -> agent.get('size') == 1 and agent.get('has flowers')
          }
        ]
      }
      {
        name: "button seed packets"
        contexts: ['buttonImage']
        rules: [
          {
            image:
              path: "images/agents/varied-plants/buttons/seedpack_1.png"
            useIf: (agent) -> agent.get('size') == 10
          }
          {
            image:
              path: "images/agents/varied-plants/buttons/seedpack_2.png"
            useIf: (agent) -> agent.get('size') == 9
          }
          {
            image:
              path: "images/agents/varied-plants/buttons/seedpack_6.png"
            useIf: (agent) -> 2 < agent.get('size') < 9
          }
          {
            image:
              path: "images/agents/varied-plants/buttons/seedpack_9.png"
            useIf: (agent) -> agent.get('size') == 2
          }
          {
            image:
              path: "images/agents/varied-plants/buttons/seedpack_10.png"
            useIf: (agent) -> agent.get('size') == 1
          }
        ]
      }
    ]
