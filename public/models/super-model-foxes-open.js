// Generated by CoffeeScript 1.7.1
(function() {
  var Agent, BasicAnimal, Environment, Events, Interactive, Rule, Species, ToolButton, Trait, env, foxSpecies, hawkSpecies, helpers, plantSpecies, rabbitSpecies;

  helpers = require('helpers');

  Environment = require('models/environment');

  Species = require('models/species');

  Agent = require('models/agent');

  Rule = require('models/rule');

  Trait = require('models/trait');

  Interactive = require('ui/interactive');

  Events = require('events');

  ToolButton = require('ui/tool-button');

  BasicAnimal = require('models/agents/basic-animal');

  plantSpecies = require('species/fast-plants-roots');

  rabbitSpecies = require('species/white-brown-rabbits');

  hawkSpecies = require('species/hawks');

  foxSpecies = require('species/foxes');

  env = require('environments/open');

  window.model = {
    run: function() {
      this.interactive = new Interactive({
        environment: env,
        speedSlider: false,
        addOrganismButtons: [
          {
            species: plantSpecies,
            imagePath: "images/agents/grass/tallgrass.png",
            traits: [
              new Trait({
                name: 'resource consumption rate',
                "default": 2
              })
            ],
            limit: 4000,
            scatter: 400,
            showRemoveButton: true
          }, {
            species: rabbitSpecies,
            imagePath: "images/agents/rabbits/rabbit2.png",
            traits: [
              new Trait({
                name: "mating desire bonus",
                "default": -20
              }), new Trait({
                name: "hunger bonus",
                "default": -10
              }), new Trait({
                name: "age",
                "default": 3
              }), new Trait({
                name: "resource consumption rate",
                "default": 10
              }), new Trait({
                name: "min offspring",
                "default": 3
              }), new Trait({
                name: "max offspring",
                "default": 10
              }), new Trait({
                name: "metabolism",
                "default": 1
              }), new Trait({
                name: "chance of being seen",
                "default": 0.17
              }), new Trait({
                name: "mating distance",
                "default": 250
              }), new Trait({
                name: "vision distance",
                "default": 500
              }), new Trait({
                name: "color",
                "default": "white"
              })
            ],
            limit: 700,
            scatter: 70,
            showRemoveButton: true
          }, {
            species: hawkSpecies,
            imagePath: "images/agents/hawks/hawk.png",
            traits: [
              new Trait({
                name: "min offspring",
                "default": 2
              }), new Trait({
                name: "max offspring",
                "default": 4
              }), new Trait({
                name: "mating distance",
                "default": 140
              }), new Trait({
                name: "eating distance",
                "default": 50
              }), new Trait({
                name: "vision distance",
                "default": 350
              }), new Trait({
                name: "metabolism",
                "default": 6
              })
            ],
            limit: 150,
            scatter: 6,
            showRemoveButton: true
          }, {
            species: foxSpecies,
            imagePath: "images/agents/foxes/fox.png",
            traits: [
              new Trait({
                name: "max offspring",
                "default": 3
              }), new Trait({
                name: "mating distance",
                "default": 220
              }), new Trait({
                name: "eating distance",
                "default": 50
              }), new Trait({
                name: "metabolism",
                "default": 3
              })
            ],
            limit: 140,
            scatter: 6,
            showRemoveButton: true
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
      this.hawkSpecies = hawkSpecies;
      this.rabbitSpecies = rabbitSpecies;
      return this.foxSpecies = foxSpecies;
    },
    setupGraph: function() {
      var outputOptions;
      outputOptions = {
        title: "Number of organisms",
        xlabel: "Time (s)",
        ylabel: "Number of organisms",
        xmax: 100,
        xmin: 0,
        ymax: 50,
        ymin: 0,
        xTickCount: 10,
        yTickCount: 10,
        xFormatter: "2d",
        yFormatter: "2d",
        realTime: false,
        fontScaleRelativeToParent: true,
        sampleInterval: Environment.DEFAULT_RUN_LOOP_DELAY / 1000,
        dataType: 'samples',
        dataColors: [[0, 170, 0], [153, 153, 187], [163, 31, 5], [222, 183, 9]]
      };
      this.outputGraph = LabGrapher('#graph', outputOptions);
      Events.addEventListener(Environment.EVENTS.RESET, (function(_this) {
        return function() {
          return _this.outputGraph.reset();
        };
      })(this));
      return Events.addEventListener(Environment.EVENTS.STEP, (function(_this) {
        return function() {
          return _this.outputGraph.addSamples(_this._countOrganisms());
        };
      })(this));
    },
    _countOrganisms: function() {
      var a, foxes, hawks, plants, rabbits, _i, _len, _ref;
      plants = 0;
      rabbits = 0;
      hawks = 0;
      foxes = 0;
      _ref = this.env.agents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        switch (a.species) {
          case this.plantSpecies:
            plants++;
            break;
          case this.rabbitSpecies:
            rabbits++;
            break;
          case this.hawkSpecies:
            hawks++;
            break;
          case this.foxSpecies:
            foxes++;
        }
      }
      return [plants, rabbits, hawks, foxes];
    },
    _showMessage: function(message, callback) {
      return helpers.showMessage(message, this.env.getView().view.parentElement, callback);
    },
    _agentsOfSpecies: function(species) {
      var a, set, _i, _len, _ref;
      set = [];
      _ref = this.env.agents;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        if (a.species === species) {
          set.push(a);
        }
      }
      return set;
    },
    _addedHawks: false,
    _hawksAreDead: false,
    _hawksRemoved: false,
    _addedRabbits: false,
    _rabbitsAreDead: false,
    _rabbitsRemoved: false,
    _endMessageShown: false,
    _timeOfExtinction: 0,
    setupPopulationControls: function() {
      Events.addEventListener(Environment.EVENTS.STEP, (function(_this) {
        return function() {
          var allFoxes, allHawks, allRabbits;
          allRabbits = _this._agentsOfSpecies(_this.rabbitSpecies);
          allHawks = _this._agentsOfSpecies(_this.hawkSpecies);
          _this._checkExtinction(allRabbits, allHawks);
          allFoxes = _this._agentsOfSpecies(_this.foxSpecies);
          _this._checkPredators(allHawks, allFoxes);
          if ((_this.env.date + 1) % 350 === 0) {
            return _this._showEndMessage();
          }
        };
      })(this));
      Events.addEventListener(Environment.EVENTS.RESET, (function(_this) {
        return function() {
          if (!_this._endMessageShown) {
            _this._showEndMessage();
          }
          _this._hawksRemoved = _this._rabbitsRemoved = _this._hawksAreDead = _this._rabbitsAreDead = _this._endMessageShown = _this._addedRabbits = _this._addedHawks = false;
          return _this._timeOfExtinction = 0;
        };
      })(this));
      return Events.addEventListener(Environment.EVENTS.USER_REMOVED_AGENTS, (function(_this) {
        return function(evt) {
          var species;
          species = evt.detail.species;
          if (species === _this.hawkSpecies) {
            return _this._hawksRemoved = true;
          } else if (species === _this.rabbitSpecies) {
            return _this._rabbitsRemoved = true;
          }
        };
      })(this));
    },
    _showEndMessage: function() {
      var popupText;
      popupText = "If you've been able to discover what happens in the model, you can continue on.\n\n" + "If not, you can keep running the model, or reset it if you want to run a new model.";
      this._showMessage(popupText);
      this.env.stop();
      return this._endMessageShown = true;
    },
    _checkExtinction: function(allRabbits, allHawks) {
      if (allRabbits.length > 0) {
        this._addedRabbits = true;
        this._rabbitsRemoved = false;
        this._rabbitsAreDead = false;
      }
      if (allHawks.length > 0) {
        this._addedHawks = true;
        this._hawksRemoved = false;
        this._hawksAreDead = false;
      }
      if (this._hawksAreDead || this._rabbitsAreDead) {
        if (this.env.date === (this._timeOfExtinction + 20)) {
          if ((this._hawksAreDead && !this._hawksRemoved) || (this._rabbitsAreDead && !this._rabbitsRemoved)) {
            return this._showEndMessage();
          }
        }
      } else if (this._addedRabbits) {
        if (allRabbits.length === 0) {
          this._rabbitsAreDead = true;
          return this._timeOfExtinction = this.env.date;
        }
      }
    },
    _setProperty: function(agents, property, value) {
      var agent, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = agents.length; _i < _len; _i++) {
        agent = agents[_i];
        _results.push(agent.set(property, value));
      }
      return _results;
    },
    _checkPredators: function(allHawks, allFoxes) {
      if (allHawks.length > 16) {
        this._setProperty(allHawks, "min offspring", 0);
        this._setProperty(allHawks, "max offspring", 1);
        this._setProperty(allHawks, "metabolism", 8);
      } else if (allHawks.length < 8) {
        this._setProperty(allHawks, "min offspring", 3);
        this._setProperty(allHawks, "max offspring", 4);
        this._setProperty(allHawks, "metabolism", 4);
      } else {
        this._setProperty(allHawks, "min offspring", 2);
        this._setProperty(allHawks, "max offspring", 3);
        this._setProperty(allHawks, "metabolism", 6);
      }
      if (allFoxes.length > 22) {
        this._setProperty(allFoxes, "min offspring", 0);
        this._setProperty(allFoxes, "max offspring", 1);
        return this._setProperty(allFoxes, "metabolism", 6);
      } else if (allFoxes.length < 10) {
        this._setProperty(allFoxes, "min offspring", 3);
        this._setProperty(allFoxes, "max offspring", 6);
        return this._setProperty(allFoxes, "metabolism", 2);
      } else if (allFoxes.length < 16) {
        this._setProperty(allFoxes, "min offspring", 3);
        this._setProperty(allFoxes, "max offspring", 4);
        return this._setProperty(allFoxes, "metabolism", 3);
      } else {
        this._setProperty(allFoxes, "min offspring", 1);
        this._setProperty(allFoxes, "max offspring", 3);
        return this._setProperty(allFoxes, "metabolism", 4);
      }
    },
    preload: ["images/agents/grass/tallgrass.png", "images/agents/rabbits/rabbit2.png", "images/agents/hawks/hawk.png", "images/agents/foxes/fox.png"]
  };

  window.onload = function() {
    return helpers.preload([model, env, plantSpecies, rabbitSpecies, hawkSpecies, foxSpecies], function() {
      model.run();
      model.setupGraph();
      return model.setupPopulationControls();
    });
  };

}).call(this);
