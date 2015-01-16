Rule = require 'models/rule'
Environment = require 'models/environment'

testAction = (test, shouldBeCalled=true)->
  rule = new Rule
    test: test
    action: ->
      undefined

  spyOn(rule, '_test').and.callThrough()
  spyOn(rule, '_action').and.callThrough()

  rule.execute(null)
  expect(rule._test).toHaveBeenCalled()
  if shouldBeCalled
    expect(rule._action).toHaveBeenCalled()
  else
    expect(rule._action).not.toHaveBeenCalled()

describe 'Rule', ->

  it 'should exist', ->
    rule = new Rule
      test: ->
        return true
      action: ->
        1 + 1
    expect(rule).toBeDefined()
    expect(rule._test).toBeDefined()
    expect(rule._action).toBeDefined()

  it 'should evaluate test() on execution', ->
    rule = new Rule
      test: ->
        false
      action: ->
        1 + 1

    spyOn(rule, '_test').and.callThrough()

    rule.execute(null)
    expect(rule._test).toHaveBeenCalled()

  it 'should evaluate action() on execution when test() returns true', ->
    testAction (-> true), true

  it 'should evaluate action() on execution when test() does not exist', ->
    rule = new Rule
      action: (-> false)

    spyOn(rule, '_action').and.callThrough()

    rule.execute(null)
    expect(rule._action).toHaveBeenCalled()

  it 'should not evaluate action() on execution when test() returns false', ->
    testAction (-> false), false

  describe 'invalid setup', ->

    it 'should throw an error if action is not defined', ->
      expect(->
        rule = new Rule
          test: ->
            return true
      ).toThrow(new Error("action is not a function!"))

    it 'should throw an error if action is not a function', ->
      expect(->
        rule = new Rule
          test: ->
            return true
          action: 0
      ).toThrow(new Error("action is not a function!"))

  describe 'edge conditions', ->
    it 'should execute action() when test() returns a truthy value', ->
      testAction (-> true), true
      testAction (-> "something"), true
      testAction (-> "false"), true
      testAction (-> 9), true
      testAction (-> {foo: "foo"}), true

    it 'should not execute action() when test() returns a falsy value', ->
      testAction (-> false), false
      testAction (-> null), false
      testAction (-> 0), false
      testAction (-> ""), false
      testAction (-> NaN), false
