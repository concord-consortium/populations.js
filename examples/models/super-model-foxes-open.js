// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const plantSpecies  = window.FastPlantsRootsSpecies;
const rabbitSpecies = window.WhiteBrownRabbitsSpecies;
const hawkSpecies   = window.HawksSpecies;
const foxSpecies    = window.FoxesSpecies;

window.model = {
  run() {
    this.interactive = new Populations.Interactive({
      environment: env,
      speedSlider: false,
      addOrganismButtons: [
        {
          species: plantSpecies,
          imagePath: "images/agents/grass/tallgrass.png",
          traits: [
            new Populations.Trait({name: 'resource consumption rate', default: 2})
          ],
          limit: 4000,
          scatter: 400,
          showRemoveButton: true
        },
        {
          species: rabbitSpecies,
          imagePath: "images/agents/rabbits/rabbit2.png",
          traits: [
            new Populations.Trait({name: "mating desire bonus", default: -20}),
            new Populations.Trait({name: "hunger bonus", default: -10}),
            new Populations.Trait({name: "age", default: 3}),
            new Populations.Trait({name: "resource consumption rate", default: 10}),
            new Populations.Trait({name: "min offspring", default: 3}),
            new Populations.Trait({name: "max offspring", default: 10}),
            new Populations.Trait({name: "metabolism", default: 1}),
            new Populations.Trait({name: "chance of being seen", default: 0.17}),
            new Populations.Trait({name: "mating distance", default: 250}),
            new Populations.Trait({name: "vision distance", default: 500}),
            new Populations.Trait({name: "color", default: "white"})
          ],
          limit: 700,
          scatter: 70,
          showRemoveButton: true
        },
        {
          species: hawkSpecies,
          imagePath: "images/agents/hawks/hawk.png",
          traits: [
            new Populations.Trait({name: "min offspring", default: 2}),
            new Populations.Trait({name: "max offspring", default: 4}),
            new Populations.Trait({name: "mating distance", default: 140}),
            new Populations.Trait({name: "eating distance", default:  50}),
            new Populations.Trait({name: "vision distance", default: 350}),
            new Populations.Trait({name: "metabolism", default: 6})
          ],
          limit: 150,
          scatter: 6,
          showRemoveButton: true
        },
        {
          species: foxSpecies,
          imagePath: "images/agents/foxes/fox.png",
          traits: [
            new Populations.Trait({name: "max offspring", default: 3}),
            new Populations.Trait({name: "mating distance", default: 220}),
            new Populations.Trait({name: "eating distance", default:  50}),
            new Populations.Trait({name: "metabolism", default: 3})
          ],
          limit: 140,
          scatter: 6,
          showRemoveButton: true
        }
      ],
      toolButtons: [
        {
          type: Populations.ToolButton.INFO_TOOL
        }
      ]});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.env = env;
    this.plantSpecies  = plantSpecies;
    this.hawkSpecies   = hawkSpecies;
    this.rabbitSpecies = rabbitSpecies;
    return this.foxSpecies    = foxSpecies;
  },

  setupGraph() {
    const outputOptions = {
      title:  "Number of organisms",
      xlabel: "Time (s)",
      ylabel: "Number of organisms",
      xmax:   100,
      xmin:   0,
      ymax:   50,
      ymin:   0,
      xTickCount: 10,
      yTickCount: 10,
      xFormatter: "2d",
      yFormatter: "2d",
      realTime: false,
      fontScaleRelativeToParent: true,
      sampleInterval: (Populations.Environment.DEFAULT_RUN_LOOP_DELAY/1000),
      dataType: 'samples',
      dataColors: [
        "#00AA00",
        "#9999BB",
        "#A31F05",
        "#DEB709"
      ]
    };

    this.outputGraph = LabGrapher('#graph', outputOptions);

    Populations.Events.addEventListener(Populations.Environment.EVENTS.RESET, () => {
      return this.outputGraph.reset();
    });

    return Populations.Events.addEventListener(Populations.Environment.EVENTS.STEP, () => {
      return this.outputGraph.addSamples(this._countOrganisms());
    });
  },

  _countOrganisms() {
    let plants = 0;
    let rabbits = 0;
    let hawks = 0;
    let foxes = 0;
    for (let a of Array.from(this.env.agents)) {
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
          break;
      }
    }
    return [plants, rabbits, hawks, foxes];
  },

  _showMessage(message, callback) {
    return Populations.helpers.showMessage(message, this.env.getView().view.parentElement, callback);
  },

  _agentsOfSpecies(species){
    const set = [];
    for (let a of Array.from(this.env.agents)) {
      if (a.species === species) { set.push(a); }
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
  setupPopulationControls() {
    Populations.Events.addEventListener(Populations.Environment.EVENTS.STEP, () => {
      const allRabbits = this._agentsOfSpecies(this.rabbitSpecies);
      const allHawks = this._agentsOfSpecies(this.hawkSpecies);
      this._checkExtinction(allRabbits, allHawks);

      const allFoxes = this._agentsOfSpecies(this.foxSpecies);
      this._checkPredators(allHawks, allFoxes);

      if (((this.env.date + 1) % 350) === 0) {
        return this._showEndMessage();
      }
    });
    Populations.Events.addEventListener(Populations.Environment.EVENTS.RESET, () => {
      if (!this._endMessageShown) { this._showEndMessage(); }
      this._hawksRemoved = (this._rabbitsRemoved = (this._hawksAreDead = (this._rabbitsAreDead = (this._endMessageShown = (this._addedRabbits = (this._addedHawks = false))))));
      return this._timeOfExtinction = 0;
    });
    return Populations.Events.addEventListener(Populations.Environment.EVENTS.USER_REMOVED_AGENTS, evt=> {
      const { species } = evt.detail;
      if (species === this.hawkSpecies) {
        return this._hawksRemoved = true;
      } else if (species === this.rabbitSpecies) {
        return this._rabbitsRemoved = true;
      }
    });
  },

  _showEndMessage() {
    const popupText = "If you've been able to discover what happens in the model, you can continue on.\n\n"+
                     "If not, you can keep running the model, or reset it if you want to run a new model.";

    this._showMessage(popupText);
    this.env.stop();
    return this._endMessageShown = true;
  },

  _checkExtinction(allRabbits, allHawks){
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
    // else if @_addedHawks and @_hawksRemoved
    //   if allHawks.length is 0
    //     @_hawksAreDead = true
    //     @_timeOfExtinction = @env.date
    } else if (this._addedRabbits) {
      if (allRabbits.length === 0) {
        this._rabbitsAreDead = true;
        return this._timeOfExtinction = this.env.date;
      }
    }
  },

  _setProperty(agents, property, value){
    return Array.from(agents).map((agent) =>
      agent.set(property, value));
  },

  _checkPredators(allHawks, allFoxes){
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

  preload: [
    "images/agents/grass/tallgrass.png",
    "images/agents/rabbits/rabbit2.png",
    "images/agents/hawks/hawk.png",
    "images/agents/foxes/fox.png"
  ]
};

window.onload = () =>
  Populations.helpers.preload([model, env, plantSpecies, rabbitSpecies, hawkSpecies, foxSpecies], function() {
    model.run();
    model.setupGraph();
    return model.setupPopulationControls();
  })
;
