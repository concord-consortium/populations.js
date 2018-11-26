// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
window.env = new Populations.Environment({
  columns:  58,
  rows:     52,
  imgPath: "images/environments/sun5levels.jpg",
  barriers: [
      [0, 0, 95, 520],     // East
      [540, 0, 40, 580],   // West
      [0, 0, 580, 60],     // Top
      [0, 105, 580, 50],   // Rows
      [0, 200, 580, 45],
      [0, 295, 580, 45],
      [0, 390, 580, 40],
      [0, 470, 580, 50]
    ],
  wrapEastWest: true,
  wrapNorthSouth: true
});

for (let col = 0; col < 58; col++) {
  for (var row = 0; row < 52; row++) {
    sunlight = (() => { switch (false) {
      case !(row < 13): return 10;
      case !(row < 22): return 8;
      case !(row < 32): return 6;
      case !(row < 41): return 4;
      default: return 2;
    } })();
    env.set(col, row, "sunlight", sunlight);
  }
}

env.addRule(new Populations.Rule({
  test(agent) {
    return agent.get('age') > (agent.species.defs.SPROUT_AGE + 4);
  },
  action(agent) {
    const size     = agent.get('size');
    sunlight = agent.get('sunlight');
    const diff = Math.abs((11 - size) - sunlight);
    const health = 1 - (diff /  20);
    return agent.set('health', health);
  }
})
);

env.addRule(new Populations.Rule({
  action(agent){
    const immortal = (agent.get('age') < (agent.species.defs.SPROUT_AGE + 10)) || (agent.get('health') >= 0.87);
    return agent.set('is immortal', immortal);
  }
})
);

env.addRule(new Populations.Rule({
  action(agent){
    const flowers = (agent.get('age') > agent.species.defs.MATURITY_AGE) && (agent.get('health') >= 0.95);
    return agent.set('has flowers', flowers);
  }
})
);