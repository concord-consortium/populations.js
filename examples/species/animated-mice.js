// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
*/

class Mouse extends Populations.helpers.mixOf(Populations.BasicAnimal, Populations.AnimatedAgent) {
  step() {
    return this.wander();
  }

  wander(speed){
    if (speed == null) {
      const defaultSpeed = this.get('default speed');
      speed = this.get('speed');
      speed += (Math.random() * 2 - 1) * .1;
      speed = Math.min(Math.max(speed, defaultSpeed * .75), defaultSpeed * 1.25);
      this.set('speed', speed);
    }
    const change = (Math.random() * 1 - .5) / 10;
    let newDir = this.get("direction") + change;
    const newAngle = (newDir * (180 / Math.PI) % 360);
    if ((newAngle > 45 && newAngle < 135) || (newAngle > 225 && newAngle < 315)) {
      newDir = this.get("direction") - change;
    }
    if (Math.random() < .03) {
      newDir = newDir + Math.PI;
    }
    this.set("direction", newDir);
    return this.move(speed);
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
      this.setMovement(Populations.AnimatedAgent.MOVEMENTS.MOVESTEP);
      return this.setLocation(newLoc);
    }
  }

}

window.MouseSpecies = new Populations.Species({
  speciesName: "mice",
  agentClass: Mouse,
  defs: {
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 1
  },
  traits: [
    new Populations.Trait({name: 'default speed', default: 8 }),
    new Populations.Trait({name: 'speed', default: 8 }),
    new Populations.Trait({name: 'direction', default: 0 }),
  ],
  imageProperties: {
    initialFlipDirection: "right"
  },
  imageRules: [
    {
      name: 'mouse',
      rules: [
        {
          image: {
            animations: [
              {
                path: "images/agents/animated-mouse/mouse-sprite.json",
                movement: "move-step",
                animationName: "walk",
                length: 3,
                loop: false,
                frameRate: 12
              },
              {
                path: "images/agents/animated-mouse/mouse-sprite.json",
                movement: "stop",
                animationName: "stop",
                length: 1,
                loop: false,
                frameRate: 12
              }
            ],
            scale: .3,
            anchor: {
              x: 0.5,
              y: 0.5
            }
          }
        }
      ]
    }
  ]});
