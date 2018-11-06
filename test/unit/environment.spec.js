// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Environment = require('models/environment');

describe('An Environment', function() {

  it('can be created with rows and columns', function() {
    const env = new Environment({
      columns: 5,
      rows: 6
    });

    expect(env.width).toBe(50);
    return expect(env.height).toBe(60);
  });

  it('can be created with width and height', function() {
    const env = new Environment({
      width: 50,
      height: 60
    });

    expect(env.columns).toBe(5);
    return expect(env.rows).toBe(6);
  });

  describe('has Cells which', () =>

    it('have properties that can be set and read', function() {
      const env = new Environment({
        columns: 5,
        rows: 5
      });

      env.set(0, 0, "sunlight", 0.5);

      return expect(env.get(0, 0, "sunlight")).toBe(0.5);
    })
  );

  describe('can have seasons which', function() {

    // this allows rules like agent.get("season") as well
    it('can be accessed by env.get()', function() {
      const env = new Environment({
        columns: 5,
        rows: 5
      });

      return expect(env.get(0, 0, "season")).toBe("spring");
    });

    return it('can have defined lengths', function() {
      let i;
      const env = new Environment({
        columns: 5,
        rows: 5,
        seasonLengths: [5, 20, 5, 3]});

      expect(env.get(0, 0, "yearLength")).toBe(33);

      for (i = 0; i < 4; i++) { env.step(); }
      expect(env.get(0, 0, "season")).toBe("spring");

      for (i = 0; i < 20; i++) { env.step(); }
      expect(env.get(0, 0, "season")).toBe("summer");

      for (i = 0; i < 5; i++) { env.step(); }
      expect(env.get(0, 0, "season")).toBe("fall");

      for (i = 0; i < 3; i++) { env.step(); }
      expect(env.get(0, 0, "season")).toBe("winter");

      for (i = 0; i < 3; i++) { env.step(); }
      return expect(env.get(0, 0, "season")).toBe("spring");
    });
  });

  return describe('can have barriers which', function() {
    it('can detect if a point is inside it', function() {
      const env = new Environment({
        columns: 10,
        rows: 10
      });

      env.addBarrier(10, 10, 10, 10);

      expect(env.isInBarrier(5,5)).toBe(false);   // outside
      expect(env.isInBarrier(15,15)).toBe(true);  // inside
      expect(env.isInBarrier(10,15)).toBe(true); // left edge
      expect(env.isInBarrier(10,15)).toBe(true); // right edge
      expect(env.isInBarrier(10,15)).toBe(true); // top edge
      expect(env.isInBarrier(10,15)).toBe(true); // bottom edge
      expect(env.isInBarrier(10,10)).toBe(true); // top-left corner
      expect(env.isInBarrier(20,10)).toBe(true); // top-right corner
      expect(env.isInBarrier(10,20)).toBe(true); // bottom-left corner
      return expect(env.isInBarrier(20,20)).toBe(true);
    }); // bottom-right corner

    return it('can detect if a line between two points intersects it', function() {
      const env = new Environment({
        columns: 10,
        rows: 10
      });

      env.addBarrier(10, 10, 10, 10);

      expect(env.crossesBarrier({x: 5, y: 5}, {x: 25, y: 5})).toBe(false);   // outside above
      expect(env.crossesBarrier({x: 5, y: 5}, {x: 15, y: 15})).toBe(true);   // ends inside
      expect(env.crossesBarrier({x: 15, y: 5}, {x: 15, y: 25})).toBe(true);   // ends outside, vertical line
      expect(env.crossesBarrier({x: 10, y: 5}, {x: 10, y: 25})).toBe(true);   // intersects along an edge, vertical line

      //intersects corner points
      expect(env.crossesBarrier({x: 15, y:  5}, {x:  5, y: 15})).toBe(true);
      expect(env.crossesBarrier({x: 15, y:  5}, {x: 25, y: 15})).toBe(true);
      expect(env.crossesBarrier({x:  5, y: 15}, {x: 15, y: 25})).toBe(true);
      expect(env.crossesBarrier({x: 15, y: 25}, {x: 25, y: 15})).toBe(true);

      //misses corners
      expect(env.crossesBarrier({x: 15, y:  5}, {x:  5, y: 14})).toBe(false);
      expect(env.crossesBarrier({x: 15, y:  5}, {x: 25, y: 14})).toBe(false);
      expect(env.crossesBarrier({x:  5, y: 15}, {x: 15, y: 26})).toBe(false);
      expect(env.crossesBarrier({x: 15, y: 26}, {x: 25, y: 15})).toBe(false);

      //slices through corners
      expect(env.crossesBarrier({x: 15, y:  5}, {x:  5, y: 16})).toBe(true);
      expect(env.crossesBarrier({x: 15, y:  5}, {x: 25, y: 16})).toBe(true);
      expect(env.crossesBarrier({x:  5, y: 15}, {x: 15, y: 24})).toBe(true);
      return expect(env.crossesBarrier({x: 15, y: 24}, {x: 25, y: 15})).toBe(true);
    });
  });
});
