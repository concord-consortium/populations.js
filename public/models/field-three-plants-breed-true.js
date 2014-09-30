// Generated by CoffeeScript 1.7.1
(function() {
  var Agent, Environment, Events, Interactive, Rule, Species, ToolButton, Trait, env, helpers, plantSpecies;

  helpers = require('helpers');

  Environment = require('models/environment');

  Species = require('models/species');

  Agent = require('models/agent');

  Rule = require('models/rule');

  Trait = require('models/trait');

  Interactive = require('interactive/interactive');

  Events = require('events');

  ToolButton = require('interactive/tool-button');

  plantSpecies = require('species/varied-plants');

  env = require('environments/sunlight-field');

  window.model = {
    run: function() {
      var shownWinterMessage;
      plantSpecies.defs.CHANCE_OF_MUTATION = 0;
      this.interactive = new Interactive({
        environment: env,
        speedSlider: true,
        addOrganismButtons: [
          {
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
          }, {
            species: plantSpecies,
            imagePath: "images/agents/varied-plants/buttons/seedpack_10.png",
            traits: [
              new Trait({
                name: "size",
                "default": 1
              }), new Trait({
                name: "root size",
                "default": 5
              })
            ]
          }, {
            species: plantSpecies,
            imagePath: "images/agents/varied-plants/buttons/seedpack_2.png",
            traits: [
              new Trait({
                name: "size",
                "default": 9
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
      this.plantSpecies = plantSpecies;

      /* message script */
      shownWinterMessage = false;
      return Events.addEventListener(Environment.EVENTS.STEP, (function(_this) {
        return function() {
          if (shownWinterMessage) {
            return;
          }
          if (_this.env.get(0, 0, "season") === "winter") {
            _this.showMessage("Winter has come and snow has fallen. <br/><br/> All your plants have died. Boo hoo! <br/><br/> But if they've flowered and dropped seeds maybe baby plants will grow.<br/> Click 'OK' and let's see what happens.", true);
            return shownWinterMessage = true;
          }
        };
      })(this));
    },
    chartData: null,
    chart: null,
    setupChart: function() {
      var options;
      this.chartData = new google.visualization.DataTable();
      this.chartData.addColumn('string', 'Plant Type (Leaf Size)');
      this.chartData.addColumn('number', 'Flowers');
      this.chartData.addColumn({
        type: 'string',
        role: 'style'
      });
      this.chartData.addRows([["1", 0, "color: #5942BF"], ["2", 0, "color: #904078"], ["3", 0, "color: #904078"], ["4", 0, "color: #904078"], ["5", 0, "color: #904078"], ["6", 0, "color: #904078"], ["7", 0, "color: #904078"], ["8", 0, "color: #904078"], ["9", 0, "color: #D34441"], ["10", 0, "color: #D34441"]]);
      options = {
        title: 'Number of Flowers',
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
      this.chart = new google.visualization.ColumnChart(document.getElementById('chart'));
      this.chart.draw(this.chartData, options);
      return Events.addEventListener(Environment.EVENTS.STEP, (function(_this) {
        return function() {
          var agent, changed, counts, existingCounts, _i, _len, _ref;
          if (_this.env.get(0, 0, "season") !== "summer") {
            return;
          }
          existingCounts = {
            1: _this.chartData.getValue(0, 1),
            5: _this.chartData.getValue(4, 1),
            9: _this.chartData.getValue(8, 1)
          };
          counts = {
            1: 0,
            5: 0,
            9: 0
          };
          _ref = _this.env.agents;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            agent = _ref[_i];
            if (agent.get('has flowers')) {
              counts[agent.get('size')] += 1;
            }
          }
          changed = existingCounts[1] !== counts[1] || existingCounts[5] !== counts[5] || existingCounts[9] !== counts[9];
          if (changed) {
            _this.chartData.setValue(0, 1, counts[1]);
            _this.chartData.setValue(4, 1, counts[5]);
            _this.chartData.setValue(8, 1, counts[9]);
            if (counts[1] > 10 || counts[5] > 10 || counts[9] > 10) {
              options.vAxis.gridlines.count = -1;
            }
            return _this.chart.draw(_this.chartData, options);
          }
        };
      })(this));
    },
    showMessage: function(message, pause) {
      if (pause == null) {
        pause = false;
      }
      if (pause) {
        this.env.stop();
      }
      return helpers.showMessage(message, this.env.getView().view.parentElement, (function(_this) {
        return function() {
          return _this.env.start();
        };
      })(this));
    },
    preload: ["images/agents/varied-plants/buttons/seedpack_2.png", "images/agents/varied-plants/buttons/seedpack_6.png", "images/agents/varied-plants/buttons/seedpack_10.png"]
  };

  window.onload = function() {
    return helpers.preload([model, env, plantSpecies], function() {
      model.run();
      return model.setupChart();
    });
  };

}).call(this);
