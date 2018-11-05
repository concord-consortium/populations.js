/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/*
  Tests describing the interaction between agents, environments, and rules
*/

const Agent = require('models/agent');
const Environment = require('models/environment');

describe('An agent in an environment', function() {

  it('should have access to its cell properties', function() {
    const env = new Environment({
      columns: 5,
      rows: 5
    });

    for (let col = 0; col <= 5; col++) {
      for (let row = 0; row <= 5; row++) {
        env.set(col, row, "sunlight", row);
      }
    }

    const agent = new Agent({environment: env});
    agent.setLocation({x: 0, y: 5});
    expect(agent.getEnvironmentProperty('sunlight')).toEqual(0);

    agent.setLocation({x: 0, y: 25});
    return expect(agent.getEnvironmentProperty('sunlight')).toEqual(2);
  });

  return describe('with rules', () =>

    it('should run the rules correctly', function() {

      const env = new Environment({
        columns: 5,
        rows: 5
      });

      for (let col = 0; col <= 5; col++) {
        for (let row = 0; row <= 5; row++) {
          env.set(col, row, "sunlight", row);
        }
      }

      env.addRule(new Rule({
        test(agent) {
          return agent.getEnvironmentProperty('sunlight') >= 2;
        },
        action(agent) {
          return agent.set('health', 1);
        }
      })
      );

      env.addRule(new Rule({
        test(agent) {
          return agent.getEnvironmentProperty('sunlight') < 2;
        },
        action(agent) {
          return agent.set('health', 0);
        }
      })
      );

      const agent = new Agent({});
      agent.set('is immortal', true);
      agent.setLocation({x: 0, y: 35});     // sunlight = 3
      env.addAgent(agent);

      env.step();

      expect(agent.get('health')).toEqual(1);

      agent.setLocation({x: 0, y: 15});     // sunlight = 0
      env.step();

      return expect(agent.get('health')).toEqual(0);
    })
  );
});

