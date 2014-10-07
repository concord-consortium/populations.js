require.register "species/animated-foxes", (exports, require, module) ->

  helpers = require 'helpers'
  Species = require 'models/species'
  BasicAnimal = require 'models/agents/basic-animal'
  AnimatedAgent = require 'models/agents/animated-agent'
  Trait   = require 'models/trait'

  class Fox extends helpers.mixOf BasicAnimal, AnimatedAgent
    step: ->
      if (Math.random() < @get 'chance-hop')
        @wander()
      else
        @setMovement AnimatedAgent.MOVEMENTS.STOP

    move: (speed) ->
      dir = @get 'direction'
      speed ?= @get 'speed'
      return if speed is 0
      throw 'invalid speed' unless typeof(speed) is 'number'
      throw 'invalid direction' unless typeof(dir) is 'number'
      loc = @getLocation()
      dx = speed * Math.cos(dir)
      dy = speed * Math.sin(dir)

      newLoc = {x: loc.x + dx, y: loc.y + dy}
      if @environment.crossesBarrier(loc, newLoc)
        # stay where you are and turn around, for now
        @set 'direction', dir + Math.PI
      else
        @setMovement AnimatedAgent.MOVEMENTS.MOVESTEP
        @setLocation newLoc


  module.exports = new Species
    speciesName: "foxes"
    agentClass: Fox
    defs:
      CHANCE_OF_MUTATION: 0
      INFO_VIEW_SCALE: 1
    traits: [
      new Trait {name: 'speed', default: 30 }
      new Trait {name: 'chance-hop', float: true, min: 0.01, max: 0.2 }
    ]
    imageRules: [
      {
        name: 'fox'
        rules: [
          {
            image:
              animations: [
                {
                  path: "images/agents/animated-fox/fox-sprite.json"
                  movement: "move-step"
                  animationName: "walk"
                  length: 4
                  loop: false
                  frameRate: 20
                }
                {
                  path: "images/agents/animated-fox/fox-sprite.json"
                  movement: "stop"
                  animationName: "walk"
                  length: 1
                  loop: false
                  frameRate: 20
                }
              ]
              scale: 1
              anchor:
                x: 0.5
                y: 0.5
          }
        ]
      }
    ]
