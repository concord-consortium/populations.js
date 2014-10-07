require.register "species/fast-plants-roots", (exports, require, module) ->

  Species = require 'models/species'
  FastPlant = require 'models/agents/fast-plant'
  Trait   = require 'models/trait'

  module.exports = new Species
    speciesName: "fast plants"
    agentClass: FastPlant
    defs:
      CHANCE_OF_MUTATION: 0
      MATURITY_AGE: 14
      INFO_VIEW_SCALE: 2.5
    traits: [
      new Trait {name: "growth rate", default: 0.0035, float: true }
      new Trait {name: "max offspring", default: 3 }
      new Trait {name: "max offspring distance", default: 200 }
      new Trait {name: "roots", possibleValues: [1,2,3], default: 2 }
      new Trait {name: "food quantity", default: 100 }
    ]
    imageRules: [
      {
        name: 'plant'
        rules: [
          {
            image:
              path: "images/agents/grass/smallgrass.png"
              scale: 0.35
              anchor:
                x: 0.5
                y: 1
            useIf: (agent)-> agent.get('roots') is 1 and agent.get('chance of survival') > 0.999
          }
          {
            image:
              path: "images/agents/grass/smallgrass-brown.png"
              scale: 0.35
              anchor:
                x: 0.5
                y: 1
            useIf: (agent)-> agent.get('roots') is 1 and agent.get('chance of survival') <= 0.999
          }
          {
            image:
              path: "images/agents/grass/medgrass.png"
              scale: 0.35
              anchor:
                x: 0.5
                y: 1
            useIf: (agent)-> agent.get('roots') is 2 and agent.get('chance of survival') > 0.999
          }
          {
            image:
              path: "images/agents/grass/medgrass-brown.png"
              scale: 0.35
              anchor:
                x: 0.5
                y: 1
            useIf: (agent)-> agent.get('roots') is 2 and agent.get('chance of survival') <= 0.999
          }
          {
            image:
              path: "images/agents/grass/tallgrass.png"
              scale: 0.35
              anchor:
                x: 0.5
                y: 1
            useIf: (agent)-> agent.get('roots') is 3 and agent.get('chance of survival') > 0.999
          }
          {
            image:
              path: "images/agents/grass/tallgrass-brown.png"
              scale: 0.35
              anchor:
                x: 0.5
                y: 1
            useIf: (agent)-> agent.get('roots') is 3 and agent.get('chance of survival') <= 0.999
          }
        ]
      }
    ]
