/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
require.register("species/animated-foxes", function(exports, require, module) {

  const helpers = require('helpers');
  const Species = require('models/species');
  const BasicAnimal = require('models/agents/basic-animal');
  const AnimatedAgent = require('models/agents/animated-agent');
  const Trait   = require('models/trait');

  class Fox extends helpers.mixOf(BasicAnimal, AnimatedAgent) {
    step() {
      if (Math.random() < this.get('chance-hop')) {
        return this.wander();
      } else {
        return this.setMovement(AnimatedAgent.MOVEMENTS.STOP);
      }
    }

    move(speed) {
      const dir = this.get('direction');
      if (speed == null) { speed = this.get('speed'); }
      if (speed === 0) { return; }
      if (typeof(speed) !== 'number') { throw new Error('invalid speed'); }
      if (typeof(dir) !== 'number') { throw new Error('invalid direction'); }
      const loc = this.getLocation();
      const dx = speed * Math.cos(dir);
      const dy = speed * Math.sin(dir);

      const newLoc = {x: loc.x + dx, y: loc.y + dy};
      if (this.environment.crossesBarrier(loc, newLoc)) {
        // stay where you are and turn around, for now
        return this.set('direction', dir + Math.PI);
      } else {
        this.setMovement(AnimatedAgent.MOVEMENTS.MOVESTEP);
        return this.setLocation(newLoc);
      }
    }
  }


  return module.exports = new Species({
    speciesName: "foxes",
    agentClass: Fox,
    defs: {
      CHANCE_OF_MUTATION: 0,
      INFO_VIEW_SCALE: 1
    },
    traits: [
      new Trait({name: 'speed', default: 30 }),
      new Trait({name: 'chance-hop', float: true, min: 0.01, max: 0.2 })
    ],
    imageProperties: {
      initialFlipDirection: "left"
    },
    imageRules: [
      {
        name: 'fox',
        rules: [
          {
            image: {
              animations: [
                {
                  path: "images/agents/animated-fox/fox-sprite.json",
                  movement: "move-step",
                  animationName: "walk",
                  length: 4,
                  loop: false,
                  frameRate: 20
                },
                {
                  path: "images/agents/animated-fox/fox-sprite.json",
                  movement: "stop",
                  animationName: "walk",
                  length: 1,
                  loop: false,
                  frameRate: 20
                }
              ],
              scale: 1,
              anchor: {
                x: 0.5,
                y: 0.5
              }
            }
          }
        ]
      }
    ]});
});
