###
  This weird function allows us to call
    expect(model('x.y.z'))
  and have it return window.model.x.y.z

  In this system, calling
    expect(model('x').y.z)
  will not return anything, so we have to do this....
###
angular.scenario.dsl 'model', ->
  return (selector) ->
    return this.addFutureAction 'model.'+selector, ($window, $document, done) ->
      selectors = selector.split(".")
      obj = $window.model
      obj = obj[select] for select in selectors
      done(null, obj);

angular.scenario.dsl 'agent', ->
  return (num, property) ->
    return this.addFutureAction 'agent['+num+"] "+property, ($window, $document, done) ->
      agent = $window.model.env.agents[num]._props[property]
      done(null, agent);

angular.scenario.dsl 'clickInModel', ->
  return (loc) ->
    return this.addFutureAction 'click model at '+loc, ($window, $document, done) ->
      document = $document[0]
      canvas = document.getElementsByTagName("canvas")[0]
      event = document.createEvent("MouseEvent")
      event.initMouseEvent("click", true, true, window, 0, 0, 0, loc.x, loc.y)
      canvas.dispatchEvent(event)
      done();

angular.scenario.dsl 'step', ->
  return (numSteps) ->
    return this.addFutureAction 'stepping model '+numSteps+' times', ($window, $document, done) ->
      for i in [0...numSteps]
        $window.model.env.step()
      done()

angular.scenario.dsl 'loiter', ->
  return (ms) ->
    return this.addFutureAction 'wait for ' + ms, ($window, $document, done) ->
      setTimeout ->
        done()
      , ms

describe 'The Five Flowerboxes Three Plants model', ->

  beforeEach ->
    browser().navigateTo( "/five-sunlight-three-plants.html" )
    loiter(300)

  it 'should exist and have three AddOrganism buttons', ->
    expect(browser().window().path()).toBe "/five-sunlight-three-plants.html"
    expect(repeater("canvas").count()).toEqual 1
    expect(repeater(".button.modal").count()).toEqual 3

  it 'should activate the modal button when we click an AddOrganism button', ->
    expect(repeater(".button.modal-active").count()).toEqual 0
    element(".button.modal:first").click()
    expect(element(".button.modal:first").attr("class")).toEqual "button modal modal-active"
    expect(repeater(".button.modal-active").count()).toEqual 1

  it 'should add agents when we use an AddOrganism button', ->
    expect(model('env.agents')).toBeDefined()
    expect(model('env.agents.length')).toBe 0

    element(".button.modal:first").click()
    clickInModel({x: 150, y: 180})
    expect(model('env.agents.length')).toBe 1

    expect(agent(0, 'age')).toBe 0
    expect(agent(0, 'is seed')).toBe true
    expect(agent(0, 'size')).toBe 1

    element(".button.modal:last").click()
    clickInModel({x: 160, y: 180})
    expect(model('env.agents.length')).toBe 2

    expect(agent(1, 'size')).toBe 9

  it 'should grow plants when the model runs', ->
    element(".button.modal:first").click()
    clickInModel({x: 150, y: 180})
    step(20)

    expect(agent(0, 'age')).toBe 20
    expect(agent(0, 'is seed')).toBe false
