Rule = require 'models/rule'
Environment = require 'models/environment'

testAction = (test, shouldBeCalled=true)->
  rule = new Rule
    test: test
    action: jasmine.createSpy("action spy")

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
      test: jasmine.createSpy("test spy").andReturn(false)
      action: ->
        1 + 1

    rule.execute(null)
    expect(rule._test).toHaveBeenCalled()

  it 'should evaluate action() on execution when test() returns true', ->
    testAction jasmine.createSpy("test spy").andReturn(true), true

  it 'should not evaluate action() on execution when test() returns false', ->
    testAction jasmine.createSpy("test spy").andReturn(false), false

  describe 'invalid setup', ->
    it 'should throw an error if test is not defined', ->
      expect(->
        rule = new Rule
          action: ->
            1 + 1
      ).toThrow(new Error("test is not a function!"))

    it 'should throw an error if action is not defined', ->
      expect(->
        rule = new Rule
          test: ->
            return true
      ).toThrow(new Error("action is not a function!"))

    it 'should throw an error if test is not a function', ->
      expect(->
        rule = new Rule
          test: true
          action: ->
            1 + 1
      ).toThrow(new Error("test is not a function!"))

    it 'should throw an error if action is not a function', ->
      expect(->
        rule = new Rule
          test: ->
            return true
          action: 0
      ).toThrow(new Error("action is not a function!"))

  describe 'edge conditions', ->
    it 'should execute action() when test() returns a truthy value', ->
      testAction jasmine.createSpy("test spy").andReturn(true), true
      testAction jasmine.createSpy("test spy").andReturn("something"), true
      testAction jasmine.createSpy("test spy").andReturn("false"), true
      testAction jasmine.createSpy("test spy").andReturn(9), true
      testAction jasmine.createSpy("test spy").andReturn({foo: "foo"}), true

    it 'should not execute action() when test() returns a falsy value', ->
      testAction jasmine.createSpy("test spy").andReturn(false), false
      testAction jasmine.createSpy("test spy").andReturn(null), false
      testAction jasmine.createSpy("test spy").andReturn(0), false
      testAction jasmine.createSpy("test spy").andReturn(""), false
      testAction jasmine.createSpy("test spy").andReturn(NaN), false
