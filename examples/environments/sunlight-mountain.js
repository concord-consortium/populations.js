/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Environment = require('models/environment');
const Rule        = require('models/rule');

const env = new Environment({
  columns:  60,
  rows:     52,
  imgPath: "images/environments/mountains1.jpg",
  seasonLengths: [30, 30, 20, 5],
  barriers: [
    [  0,   0,  39, 520],
    [561,   0,  39, 520]
  ],
  wrapEastWest: false,
  wrapNorthSouth: false
});

for (let col = 0; col <= 60; col++) {
  for (let row = 0; row <= 52; row++) {
    env.set(col, row, "sunlight", 6);
  }
}

// Health depends on size and sunlight
env.addRule(new Rule({
  action(agent) {
    const size     = agent.get('size');
    const sunlight = agent.get('sunlight');
    const diff = Math.abs((11 - size) - sunlight);
    const health = 1 - (diff/20.0);
    return agent.set('health', health);
  }
})
);

// No withered plant can flower
env.addRule(new Rule({
  action(agent) {
    const health = agent.get('health');
    return agent.set('chance of flowering', (health > 0.99 ? 1 : 0));
  }
})
);

// Healthy and withered plants are immortal until fall
env.addRule(new Rule({
  test(agent) {
    const season = agent.get('season');
    return (agent.get('health') > 0.9) && ((season === "spring") || (season === "summer"));
  },
  action(agent) {
    return agent.set('is immortal', true);
  }
})
);

env.addRule(new Rule({
  test(agent) {
    return agent.get('season') === "fall";
  },
  action(agent) {
    return agent.set('is immortal', false);
  }
})
);

require.register("environments/sunlight-mountain", (exports, require, module) => module.exports = env);
