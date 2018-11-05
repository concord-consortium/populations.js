/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Environment = require('models/environment');
const Rule        = require('models/rule');
const Trait       = require('models/trait');
const BasicAnimal = require('models/agents/basic-animal');
const FastPlant   = require('models/agents/fast-plant');

const env = new Environment({
  columns:  50,
  rows:     50,
  imgPath: "images/environments/dam-year0.png",
  seasonLengths: [30, 30, 15, 10],
  barriers: [
    [0, 247, 500, 20]
  ],
  wrapEastWest: false,
  wrapNorthSouth: false
});

env.addRule(new Rule({
  test(agent){
    return agent instanceof BasicAnimal && (agent.get('prey').length === 0);
  },
  action(agent) {
    // Set the right prey based on size
    const trait = new Trait({name: 'roots', possibleValues: [agent.get('size')]});
    return agent.set('prey', [{name: 'fast plants', traits: [trait]}]);
  }}));

// plants with roots 1
env.addRule(new Rule({
  test(agent){
    return agent instanceof FastPlant && (agent.get('roots') === 1);
  },
  action(agent){
    const water = agent.get('water')/10.0;
    let pop_size_mod = agent.get('population size modifier');
    if (water < 0.8) { pop_size_mod = 0; }
    const distFrom90 = Math.max(0.9-water, 0.0);
    const dryness = Math.min(1.0, distFrom90/0.4);

    // chance of survival is 1.0 at water > 0.9, 0.8 at water < 0.5, and decreases linearly between
    agent.set('chance of survival', (1 - (dryness * 0.2)));
    // growth rate is 0.04 at water > 0.9, 0 at water < 0.5, and decreases linearly between
    return agent.set('growth rate', ((0.04 - (dryness * .04)) + pop_size_mod));
  }
})
);

// plants with roots 2
env.addRule(new Rule({
  test(agent){
    return agent instanceof FastPlant && (agent.get('roots') === 2);
  },
  action(agent){
    const water = agent.get('water')/10;
    let pop_size_mod = agent.get('population size modifier');
    if (water < 0.6) { pop_size_mod = 0; }
    const distFrom70 = Math.max(0.7-water, 0.0);
    const dryness = Math.min(1.0, distFrom70/0.4);

    // chance of survival is 1.0 at water > 0.7, 0.8 at water < 0.3, and decreases linearly between
    agent.set('chance of survival', (1 - (dryness * 0.2)));
    // growth rate is 0.04 at water > 0.7, 0 at water < 0.3, and decreases linearly between
    return agent.set('growth rate', ((0.04 - (dryness * .04)) + pop_size_mod));
  }
})
);

// plants with roots 3
env.addRule(new Rule({
  test(agent){
    return agent instanceof FastPlant && (agent.get('roots') === 3);
  },
  action(agent){
    const pop_size_mod = agent.get('population size modifier');

    // growth rate doesn't depend on the amount of water
    return agent.set('growth rate', (0.04 + pop_size_mod));
  }
})
);

require.register("environments/dam", (exports, require, module) => module.exports = env);
