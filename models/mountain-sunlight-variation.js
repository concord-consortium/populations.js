// Generated by CoffeeScript 1.6.3
(function() {
  var Agent, Environment, Events, Interactive, Rule, Species, ToolButton, Trait, env, helpers, plantSpecies;

  helpers = require('helpers');

  Environment = require('models/environment');

  Species = require('models/species');

  Agent = require('models/agent');

  Rule = require('models/rule');

  Trait = require('models/trait');

  Interactive = require('ui/interactive');

  Events = require('events');

  ToolButton = require('ui/tool-button');

  plantSpecies = require('species/varied-plants');

  env = require('environments/sunlight-mountain');

  window.model = {
    emptyBarriers: [[0, 0, 39, 520], [561, 0, 39, 520]],
    mountainBarriers: [[0, 0, 39, 520], [561, 0, 39, 520], [140, 490, 25, 30], [165, 450, 25, 70], [190, 300, 30, 220], [220, 150, 40, 370], [260, 70, 25, 450], [285, 0, 50, 520], [335, 0, 25, 490], [360, 0, 25, 335], [385, 0, 20, 260], [405, 0, 20, 160]],
    run: function() {
      plantSpecies.defs.CHANCE_OF_MUTATION = 0.21;
      plantSpecies.setMutatable('root size', false);
      this.interactive = new Interactive({
        environment: env,
        speedSlider: true,
        addOrganismButtons: [
          {
            scatter: 8,
            limit: 40,
            species: plantSpecies,
            imagePath: "images/agents/varied-plants/buttons/seedpack_6.png",
            traits: [
              new Trait({
                name: "size",
                "default": 5
              }), new Trait({
                name: "root size",
                "default": 5
              })
            ]
          }
        ],
        toolButtons: [
          {
            type: ToolButton.INFO_TOOL
          }
        ]
      });
      document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());
      this.env = env;
      return this.plantSpecies = plantSpecies;
    },
    setupMountains: function() {
      var mountains1, mountains2, mountains3, mountains4, mountains5,
        _this = this;
      mountains1 = document.getElementById('mountains1');
      mountains2 = document.getElementById('mountains2');
      mountains3 = document.getElementById('mountains3');
      mountains4 = document.getElementById('mountains4');
      mountains5 = document.getElementById('mountains5');
      mountains1.onclick = function() {
        return _this._updateMountains("images/environments/mountains1.jpg", _this.emptyBarriers, 6, 6);
      };
      mountains2.onclick = function() {
        return _this._updateMountains("images/environments/mountains2flipped.jpg", _this.mountainBarriers, 7, 5);
      };
      mountains3.onclick = function() {
        return _this._updateMountains("images/environments/mountains3flipped.jpg", _this.mountainBarriers, 8, 4);
      };
      mountains4.onclick = function() {
        return _this._updateMountains("images/environments/mountains4flipped.jpg", _this.mountainBarriers, 9, 3);
      };
      mountains5.onclick = function() {
        return _this._updateMountains("images/environments/mountains5flipped.jpg", _this.mountainBarriers, 10, 2);
      };
      return Events.addEventListener(Environment.EVENTS.RESET, function() {
        return mountains1.click();
      });
    },
    _updateMountains: function(imgPath, barriers, leftSunlight, rightSunlight) {
      var agent, col, light, loc, row, _i, _j, _k, _len, _ref, _results;
      this.env.setBackground(imgPath);
      this.env.setBarriers(barriers);
      for (col = _i = 0; _i <= 60; col = ++_i) {
        light = col > 30 ? rightSunlight : leftSunlight;
        for (row = _j = 0; _j <= 52; row = ++_j) {
          this.env.set(col, row, "sunlight", light);
        }
      }
      _ref = this.env.agents;
      _results = [];
      for (_k = 0, _len = _ref.length; _k < _len; _k++) {
        agent = _ref[_k];
        loc = agent.getLocation();
        if (this.env.isInBarrier(loc.x, loc.y)) {
          _results.push(agent.die());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    showMessage: function(message, callback) {
      return helpers.showMessage(message, this.env.getView().view.parentElement, callback);
    },
    setupMessages: function() {
      var allAgents, extinctionCount, shownMessage, successful, userAddedAgents, yearsSuccessful,
        _this = this;
      extinctionCount = 0;
      successful = false;
      userAddedAgents = false;
      yearsSuccessful = 0;
      shownMessage = false;
      allAgents = [];
      Events.addEventListener(Environment.EVENTS.RESET, function() {
        userAddedAgents = false;
        yearsSuccessful = 0;
        shownMessage = false;
        return allAgents = [];
      });
      Events.addEventListener(Environment.EVENTS.AGENT_ADDED, function() {
        return userAddedAgents = true;
      });
      return Events.addEventListener(Environment.EVENTS.SEASON_CHANGED, function(evt) {
        var allExtinct, halfExtinct, mountainHeight, sunlightTopLeft, willAnyoneSurvive;
        if (!shownMessage) {
          if (evt.detail.season === "winter" || evt.detail.season === "spring") {
            return;
          }
          allAgents = _this.env.agents;
          allExtinct = false;
          halfExtinct = false;
          willAnyoneSurvive = false;
          if (allAgents.length === 0) {
            allExtinct = true;
          } else {
            sunlightTopLeft = _this.env.get(0, 0, "sunlight");
            mountainHeight = sunlightTopLeft - 6;
            if (mountainHeight === 0) {
              return;
            }
            halfExtinct = _this._getSideIsExtinct();
            if (halfExtinct) {
              willAnyoneSurvive = _this._getWillAnyoneSurvive();
            }
          }
          if (allExtinct || halfExtinct) {
            if (successful && (allExtinct || willAnyoneSurvive)) {
              _this.showMessage("The plants went extinct. Why did the plants go\nextinct when the mountains changed quickly?");
              env.stop();
              extinctionCount++;
            } else if (extinctionCount === 0) {
              if (allExtinct) {
                _this.showMessage("Your plants went extinct. Click reset and try again.");
                env.stop();
                extinctionCount++;
              } else if (willAnyoneSurvive) {
                _this.showMessage("Your plants went extinct on one side. Remember, the challenge is to have flowering plants\ngrowing on both sides of the mountains. Click reset and try again.");
                env.stop();
                extinctionCount++;
              }
            } else {
              if (allExtinct) {
                _this.showMessage("Your plants went extinct again. The environment changed too quickly.\nWait a few seasons before you change the mountain height.");
                env.stop();
                extinctionCount++;
              } else if (willAnyoneSurvive) {
                _this.showMessage("Half your plants went extinct again. The environment changed too quickly.\nWait a few seasons before you change the mountain height.");
                env.stop();
                extinctionCount++;
              }
            }
            shownMessage = true;
            return;
          }
          if (mountainHeight === 4) {
            if (evt.detail.season === "fall") {
              if (_this._atLeastTenPlantsHealthyOnBothSides()) {
                yearsSuccessful++;
                if (yearsSuccessful > 1) {
                  successful = true;
                  if (extinctionCount > 0) {
                    _this.showMessage("Great job! The mountains grew slowly enough so that the plants could evolve.\nTake a Snapshot to help answer the question.");
                    env.stop();
                    return shownMessage = true;
                  } else {
                    _this.showMessage("Congratulations! The mountains grew slowly and the plants had time to evolve.\n Take a Snapshot to help answer the question.\nThen click reset and try changing the environment quickly. What do you think will happen?");
                    env.stop();
                    return shownMessage = true;
                  }
                }
              }
            }
          }
        }
      });
    },
    _getSideIsExtinct: function() {
      var agent, eastAlive, westAlive, x, _i, _len, _ref;
      eastAlive = false;
      westAlive = false;
      _ref = this.env.agents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        agent = _ref[_i];
        x = agent.getLocation().x;
        if (x < ((this.env.columns / 2) * this.env._columnWidth)) {
          eastAlive = true;
        } else {
          westAlive = true;
        }
        if (eastAlive && westAlive) {
          return false;
        }
      }
      return true;
    },
    _getWillAnyoneSurvive: function() {
      var agent, healthy, _i, _len, _ref;
      _ref = this.env.agents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        agent = _ref[_i];
        healthy = agent.get("health") > 0.99;
        if (healthy) {
          return true;
        }
      }
      return false;
    },
    _atLeastTenPlantsHealthyOnBothSides: function() {
      var agent, eastHealthyCount, westHealthyCount, x, _i, _len, _ref;
      eastHealthyCount = 0;
      westHealthyCount = 0;
      _ref = this.env.agents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        agent = _ref[_i];
        if (agent.get("health") > 0.99 && !agent.get("is seed")) {
          x = agent.getLocation().x;
          if (x < ((this.env.columns / 2) * this.env._columnWidth)) {
            eastHealthyCount++;
          } else {
            westHealthyCount++;
          }
        }
        if (eastHealthyCount >= 10 && westHealthyCount >= 10) {
          return true;
        }
      }
      return false;
    },
    chartData: null,
    chart: null,
    setupChart: function() {
      var domChart, options, toggleButton,
        _this = this;
      domChart = document.getElementById('chart');
      if (domChart != null) {
        toggleButton = document.getElementById('chart-visibility');
        if (toggleButton != null) {
          toggleButton.onclick = function() {
            if (toggleButton.innerHTML === "Show Graph") {
              domChart.style.display = "block";
              return toggleButton.innerHTML = "Hide Graph";
            } else {
              domChart.style.display = "none";
              return toggleButton.innerHTML = "Show Graph";
            }
          };
        }
        this.chartData = new google.visualization.DataTable();
        this.chartData.addColumn('string', 'Plant Type (Leaf Size)');
        this.chartData.addColumn('number', 'Number of plants');
        this.chartData.addColumn({
          type: 'string',
          role: 'style'
        });
        this.chartData.addRows([["1", 0, "color: #5942BF"], ["2", 0, "color: #5F42B8"], ["3", 0, "color: #65429F"], ["4", 0, "color: #73419E"], ["5", 0, "color: #874084"], ["6", 0, "color: #904078"], ["7", 0, "color: #9F416B"], ["8", 0, "color: #B5435A"], ["9", 0, "color: #C84349"], ["10", 0, "color: #D34441"]]);
        options = {
          title: 'Number of flowers',
          hAxis: {
            title: 'Plant Type (Leaf Size)'
          },
          vAxis: {
            title: 'Flowers',
            minValue: 0,
            maxValue: 10,
            gridlines: {
              count: 6
            }
          },
          legend: {
            position: 'none'
          },
          width: 500,
          height: 400
        };
        this.chart = new google.visualization.ColumnChart(domChart);
        this.chart.draw(this.chartData, options);
        return Events.addEventListener(Environment.EVENTS.STEP, function() {
          var agent, counts, i, _i, _j, _k, _len, _ref;
          if (_this.env.get(0, 0, "season") !== "summer") {
            return;
          }
          counts = [];
          for (i = _i = 0; _i <= 9; i = ++_i) {
            counts.push(0);
          }
          _ref = _this.env.agents;
          for (_j = 0, _len = _ref.length; _j < _len; _j++) {
            agent = _ref[_j];
            if (agent.get('has flowers')) {
              counts[agent.get('size')] += 1;
            }
          }
          for (i = _k = 0; _k <= 8; i = ++_k) {
            _this.chartData.setValue(i, 1, counts[i + 1]);
          }
          if (counts[1] > 10 || counts[5] > 10 || counts[9] > 10) {
            options.vAxis.gridlines.count = -1;
          }
          return _this.chart.draw(_this.chartData, options);
        });
      }
    },
    preload: ["images/agents/varied-plants/buttons/seedpack_10.png", "images/environments/mountains1.jpg", "images/environments/mountains2flipped.jpg", "images/environments/mountains3flipped.jpg", "images/environments/mountains4flipped.jpg", "images/environments/mountains5flipped.jpg"]
  };

  window.onload = function() {
    return helpers.preload([model, env, plantSpecies], function() {
      model.run();
      model.setupMountains();
      model.setupMessages();
      return model.setupChart();
    });
  };

}).call(this);
