require.register "species/varied-plants", (exports, require, module) ->

  Species = require 'models/species'
  Agent   = require 'models/agent'
  Trait   = require 'models/trait'

  module.exports = new Species
    agentClass: Agent
    traits: [
      new Trait {name: "size", possibleValues: [1, 5, 10]}
      new Trait {name: "health", min: 0, max: 1, default: 1, float: true}
    ]
    imageRules: [
      {
        name: 'layer1'
        rules: [
          {
            image:
              path: "images/agents/varied-plants/seed.png"
              width: 20
              height: 20
            useIf: (agent) -> agent.get('age') < 10
          }
          {
            image:
              path: "images/agents/varied-plants/leaves10.png"
            useIf: (agent) -> agent.get('size') == 1 and agent.get('health') > 0.5
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted10.png"
            useIf: (agent) -> agent.get('size') == 1 and agent.get('health') <= 0.5
          }
          {
            image:
              path: "images/agents/varied-plants/leaves5.png"
            useIf: (agent) -> agent.get('size') == 5 and agent.get('health') > 0.5
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted5.png"
            useIf: (agent) -> agent.get('size') == 5 and agent.get('health') <= 0.5
          }
          {
            image:
              path: "images/agents/varied-plants/leaves1.png"
            useIf: (agent) -> agent.get('size') == 10 and agent.get('health') > 0.5
          }
          {
            image:
              path: "images/agents/varied-plants/leaves_wilted1.png"
            useIf: (agent) -> agent.get('size') == 10 and agent.get('health') <= 0.5
          }
        ]
      }
      {
        name: "flowers"
        rules: [
          {
            image:
              path: "images/agents/varied-plants/flower1.png"
              width: 30
              height: 30
            useIf: (agent) -> agent.get('has flowers')
          }
        ]
      }
    ]
