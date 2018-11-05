/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS202: Simplify dynamic range loops
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/*
  This weird function allows us to call
    expect(model('x.y.z'))
  and have it return window.model.x.y.z

  In this system, calling
    expect(model('x').y.z)
  will not return anything, so we have to do this....
*/
angular.scenario.dsl('model', () =>
  function(selector) {
    return this.addFutureAction(`model.${selector}`, function($window, $document, done) {
      const selectors = selector.split(".");
      let obj = $window.model;
      for (let select of Array.from(selectors)) { obj = obj[select]; }
      return done(null, obj);
    });
  }
);

angular.scenario.dsl('agent', () =>
  function(num, property) {
    return this.addFutureAction(`agent[${num}] ${property}`, function($window, $document, done) {
      const agent = $window.model.env.agents[num]._props[property];
      return done(null, agent);
    });
  }
);

angular.scenario.dsl('clickInModel', () =>
  function(loc) {
    return this.addFutureAction(`click model at ${loc}`, function($window, $document, done) {
      const document = $document[0];
      const canvas = document.getElementsByTagName("canvas")[0];
      const event = document.createEvent("MouseEvent");
      event.initMouseEvent("click", true, true, window, 0, 0, 0, loc.x, loc.y);
      canvas.dispatchEvent(event);
      return done();
    });
  }
);

angular.scenario.dsl('step', () =>
  function(numSteps) {
    return this.addFutureAction(`stepping model ${numSteps} times`, function($window, $document, done) {
      for (let i = 0, end = numSteps, asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) {
        $window.model.env.step();
      }
      return done();
    });
  }
);

angular.scenario.dsl('loiter', () =>
  function(ms) {
    return this.addFutureAction(`wait for ${ms}`, ($window, $document, done) =>
      setTimeout(() => done()
      , ms)
    );
  }
);

describe('The Five Flowerboxes Three Plants model', function() {

  beforeEach(function() {
    browser().navigateTo( "/five-sunlight-three-plants.html" );
    return loiter(300);
  });

  it('should exist and have three AddOrganism buttons', function() {
    expect(browser().window().path()).toBe("/five-sunlight-three-plants.html");
    expect(repeater("canvas").count()).toEqual(1);
    return expect(repeater(".button.modal").count()).toEqual(3);
  });

  it('should activate the modal button when we click an AddOrganism button', function() {
    expect(repeater(".button.modal-active").count()).toEqual(0);
    element(".button.modal:first").click();
    expect(element(".button.modal:first").attr("class")).toEqual("button modal modal-active");
    return expect(repeater(".button.modal-active").count()).toEqual(1);
  });

  it('should add agents when we use an AddOrganism button', function() {
    expect(model('env.agents')).toBeDefined();
    expect(model('env.agents.length')).toBe(0);

    element(".button.modal:first").click();
    clickInModel({x: 150, y: 180});
    expect(model('env.agents.length')).toBe(1);

    expect(agent(0, 'age')).toBe(0);
    expect(agent(0, 'is seed')).toBe(true);
    expect(agent(0, 'size')).toBe(1);

    element(".button.modal:last").click();
    clickInModel({x: 160, y: 180});
    expect(model('env.agents.length')).toBe(2);

    return expect(agent(1, 'size')).toBe(9);
  });

  return it('should grow plants when the model runs', function() {
    element(".button.modal:first").click();
    clickInModel({x: 150, y: 180});
    step(20);

    expect(agent(0, 'age')).toBe(20);
    return expect(agent(0, 'is seed')).toBe(false);
  });
});
