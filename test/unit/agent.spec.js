// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Agent = require('models/agent');
const BasicPlant = require('models/agents/basic-plant');
const Environment = require('models/environment');
const Species = require('models/species');
const Trait   = require('models/trait');

describe('Agent', function() {

  it('should exist', function() {
    const agent = new Agent({name: "myAgent"});
    expect(agent).toBeDefined();
    return expect(agent.name).toBe("myAgent");
  });

  it('should have default properties', function() {
    const agent = new Agent({name: "myAgent"});
    return expect(agent.get('min offspring')).toEqual(1);
  });

  it('should inherit and add new default properties', function() {
    const agent = new BasicPlant({name: "myAgent"});
    expect(agent.get('min offspring')).toEqual(1);
    return expect(agent.get('is seed')).toEqual(true);
  });

  describe('Locations', function() {

    it('should have a location when set in the constructor', function() {
      const agent = new Agent({
        x: 0,
        y: 1
      });
      expect(agent._x).toBe(0);
      expect(agent._y).toBe(1);
      const loc = agent.getLocation();
      expect(loc.x).toBe(0);
      return expect(loc.y).toBe(1);
    });

    it('should not have a location when x is not set in the constructor', function() {
      const agent = new Agent({
        y: 3});
      expect(agent._x).not.toBeDefined();
      expect(agent._y).not.toBeDefined();
      const loc = agent.getLocation();
      expect(loc.x).not.toBeDefined();
      return expect(loc.y).not.toBeDefined();
    });

    it('should not have a location when y is not set in the constructor', function() {
      const agent = new Agent({
        x: 3});
      expect(agent._x).not.toBeDefined();
      expect(agent._y).not.toBeDefined();
      const loc = agent.getLocation();
      expect(loc.x).not.toBeDefined();
      return expect(loc.y).not.toBeDefined();
    });

    it('should not have a location when y is not set in the constructor', function() {
      const agent = new Agent({
        name: "myAgent"});
      expect(agent._x).not.toBeDefined();
      expect(agent._y).not.toBeDefined();
      const loc = agent.getLocation();
      expect(loc.x).not.toBeDefined();
      return expect(loc.y).not.toBeDefined();
    });

    return describe('in Environments', function() {
      describe('with no boundary wrapping', function() {
        it('should constrain the x location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100
          });
          const agent = new Agent({
            environment: env,
            x: 105,
            y: 95
          });
          expect(agent._x).toBe(94);
          return expect(agent._y).toBe(95);
        });

        it('should constrain the y location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100
          });
          const agent = new Agent({
            environment: env,
            x: 85,
            y: 115
          });
          expect(agent._x).toBe(85);
          return expect(agent._y).toBe(84);
        });

        return it('should constrain the location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100
          });
          const agent = new Agent({
            environment: env,
            x: 175,
            y: 115
          });
          expect(agent._x).toBe(24);
          return expect(agent._y).toBe(84);
        });
      });

      describe('with all boundary wrapping', function() {
        it('should constrain the x location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: true
          });
          const agent = new Agent({
            environment: env,
            x: 105,
            y: 95
          });
          expect(agent._x).toBe(5);
          return expect(agent._y).toBe(95);
        });

        it('should constrain the y location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: true
          });
          const agent = new Agent({
            environment: env,
            x: 85,
            y: 115
          });
          expect(agent._x).toBe(85);
          return expect(agent._y).toBe(15);
        });

        return it('should constrain the location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: true
          });
          const agent = new Agent({
            environment: env,
            x: 175,
            y: 115
          });
          expect(agent._x).toBe(75);
          return expect(agent._y).toBe(15);
        });
      });

      describe('with mixed boundary wrapping', function() {
        it('should constrain the x location to the environment size (wrapping)', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: false
          });
          const agent = new Agent({
            environment: env,
            x: 105,
            y: 95
          });
          expect(agent._x).toBe( 5);
          return expect(agent._y).toBe(95);
        });

        it('should constrain the x location to the environment size (no wrapping)', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: false,
            wrapNorthSouth: true
          });
          const agent = new Agent({
            environment: env,
            x: 105,
            y: 95
          });
          expect(agent._x).toBe(94);
          return expect(agent._y).toBe(95);
        });

        it('should constrain the y location to the environment size (wrapping)', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: false,
            wrapNorthSouth: true
          });
          const agent = new Agent({
            environment: env,
            x: 85,
            y: 115
          });
          expect(agent._x).toBe(85);
          return expect(agent._y).toBe(15);
        });

        it('should constrain the y location to the environment size (no wrapping)', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: false
          });
          const agent = new Agent({
            environment: env,
            x: 85,
            y: 115
          });
          expect(agent._x).toBe(85);
          return expect(agent._y).toBe(84);
        });

        it('should constrain the location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: false,
            wrapNorthSouth: true
          });
          const agent = new Agent({
            environment: env,
            x: 175,
            y: 115
          });
          expect(agent._x).toBe(24);
          return expect(agent._y).toBe(15);
        });

        return it('should constrain the location to the environment size', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: false
          });
          const agent = new Agent({
            environment: env,
            x: 175,
            y: 115
          });
          expect(agent._x).toBe(75);
          return expect(agent._y).toBe(84);
        });
      });

      return describe('with barriers', function() {

        it('should not be able to be placed on a barrier', function() {
          const env = new Environment({
            width: 100,
            height: 100
          });

          env.addBarrier(20, 20, 10, 10);

          const agent1 = new Agent({
            environment: env,
            x: 5,
            y: 5
          });

          const retValue = env.addAgent(agent1);

          expect(retValue).not.toBe(false);
          expect(env.agents.length).toBe(1);

          const agent2 = new Agent({
            environment: env,
            x: 25,
            y: 25
          });

          const retValue2 = env.addAgent(agent2);

          expect(retValue2).toBe(false);
          return expect(env.agents.length).toBe(1);
        });

        return it('should respect wrapping', function() {
          const env = new Environment({
            width: 100,
            height: 100,
            wrapEastWest: true,
            wrapNorthSouth: true
          });

          env.addBarrier(20, 20, 10, 10);

          const agent1 = new Agent({
            environment: env,
            x: 105,
            y: 105
          });

          const retValue = env.addAgent(agent1);

          expect(retValue).not.toBe(false);
          expect(env.agents.length).toBe(1);

          const agent2 = new Agent({
            environment: env,
            x: 125,
            y: 125
          });

          const retValue2 = env.addAgent(agent2);

          expect(retValue2).toBe(false);
          return expect(env.agents.length).toBe(1);
        });
      });
    });
  });

  describe('Aging', function() {
    it('should have a default age of 0', function() {
      const agent = new Agent({});
      return expect(agent.get('age')).toBe(0);
    });

    it('should increment age by 1 per step', function() {
      const agent = new Agent({});
      agent.set('is immortal', true);

      agent.step();
      agent.step();
      expect(agent.get('age')).toBe(2);

      agent.step();
      agent.step();
      agent.step();
      return expect(agent.get('age')).toBe(5);
    });

    it('should increment agent age when environment.step() is called', function() {
      const env = new Environment({columns: 5, rows: 5});
      const agent = new Agent({x: 0, y: 0});
      agent.set('is immortal', true);
      env.addAgent(agent);

      env.step();
      env.step();
      env.step();
      return expect(agent.get('age')).toBe(3);
    });

    return it('should increment agent ages independently', function() {
      const env = new Environment({columns: 5, rows: 5});
      const agent1 = new Agent({x: 0, y: 0});
      agent1.set('is immortal', true);
      const agent2 = new Agent({x: 0, y: 0});
      agent2.set('is immortal', true);
      env.addAgent(agent1);

      env.step();
      env.step();
      env.addAgent(agent2);
      env.step();
      expect(agent1.get('age')).toBe(3);
      return expect(agent2.get('age')).toBe(1);
    });
  });

  return describe('can reproduce', function() {

    let plant = null;
    let plantSpecies = null;
    beforeEach(function() {
      plantSpecies = new Species({
        agentClass: Agent,
        traits: [
          new Trait({name: "leaves", min: 1, max: 5}),
          new Trait({name: "height", min: 1, max: 10})
        ]});
      plantSpecies.defs.CHANCE_OF_MUTATION = 0;
      return plant = plantSpecies.createAgent([ new Trait({name: "leaves", default: 3}) ]);
    });

    it('and create a newborn clone', function() {
      plant.set('age', 100);

      const offspring = plant.createOffspring();

      expect(offspring).toBeDefined();
      expect(offspring).not.toBeNull();

      expect(offspring.get('age')).toEqual(0);
      return expect(offspring.get('leaves')).toEqual(3);
    });

    it('and add its offspring to the environment near itself', function() {
      const env = new Environment({columns: 10, rows: 10});
      plant.setLocation({x: 50, y: 50});
      env.addAgent(plant);

      const minDist = plant.get('min offspring distance');
      const maxDist = plant.get('max offspring distance');

      return (() => {
        const result = [];
        for (let i = 0; i < 10; i++) {
          const offspring = plant.createOffspring();
          const loc = offspring.getLocation();
          const xSq = (loc.x - 50) * (loc.x - 50);
          const ySq = (loc.y - 50) * (loc.y - 50);
          const dist = Math.round(Math.sqrt(xSq + ySq));

          expect(dist).toBeGreaterThan(minDist-1.5);
          result.push(expect(dist).toBeLessThan(maxDist+1.5));
        }
        return result;
      })();
    });

    return it('and have mutated offspring', function() {
      plantSpecies.setMutatable('leaves', true);
      plantSpecies.defs.CHANCE_OF_MUTATION = 1;

      const offspring = plant.createOffspring();

      expect(offspring.get('leaves')).not.toEqual(3);
      return expect(offspring.get('height')).toEqual(plant.get('height'));
    });
  });
});
