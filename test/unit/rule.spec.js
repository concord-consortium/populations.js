// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Rule = require('models/rule');
const Environment = require('models/environment');

const testAction = function(test, shouldBeCalled){
  if (shouldBeCalled == null) { shouldBeCalled = true; }
  const rule = new Rule({
    test,
    action() {
      return undefined;
    }
  });

  spyOn(rule, '_test').and.callThrough();
  spyOn(rule, '_action').and.callThrough();

  rule.execute(null);
  expect(rule._test).toHaveBeenCalled();
  if (shouldBeCalled) {
    return expect(rule._action).toHaveBeenCalled();
  } else {
    return expect(rule._action).not.toHaveBeenCalled();
  }
};

describe('Rule', function() {

  it('should exist', function() {
    const rule = new Rule({
      test() {
        return true;
      },
      action() {
        return 1 + 1;
      }
    });
    expect(rule).toBeDefined();
    expect(rule._test).toBeDefined();
    return expect(rule._action).toBeDefined();
  });

  it('should evaluate test() on execution', function() {
    const rule = new Rule({
      test() {
        return false;
      },
      action() {
        return 1 + 1;
      }
    });

    spyOn(rule, '_test').and.callThrough();

    rule.execute(null);
    return expect(rule._test).toHaveBeenCalled();
  });

  it('should evaluate action() on execution when test() returns true', () => testAction((() => true), true));

  it('should evaluate action() on execution when test() does not exist', function() {
    const rule = new Rule({
      action() { return false; }});

    spyOn(rule, '_action').and.callThrough();

    rule.execute(null);
    return expect(rule._action).toHaveBeenCalled();
  });

  it('should not evaluate action() on execution when test() returns false', () => testAction((() => false), false));

  describe('invalid setup', function() {

    it('should throw an error if action is not defined', () =>
      expect(function() {
        let rule;
        return rule = new Rule({
          test() {
            return true;
          }});
      }).toThrow(new Error("action is not a function!"))
    );

    return it('should throw an error if action is not a function', () =>
      expect(function() {
        let rule;
        return rule = new Rule({
          test() {
            return true;
          },
          action: 0});
      }).toThrow(new Error("action is not a function!"))
    );
  });

  return describe('edge conditions', function() {
    it('should execute action() when test() returns a truthy value', function() {
      testAction((() => true), true);
      testAction((() => "something"), true);
      testAction((() => "false"), true);
      testAction((() => 9), true);
      return testAction((() => ({foo: "foo"})), true);
    });

    return it('should not execute action() when test() returns a falsy value', function() {
      testAction((() => false), false);
      testAction((() => null), false);
      testAction((() => 0), false);
      testAction((() => ""), false);
      return testAction((() => NaN), false);
    });
  });
});
