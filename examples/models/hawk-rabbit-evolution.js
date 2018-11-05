/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const helpers     = require('helpers');

const Environment = require('models/environment');
const Species     = require('models/species');
const Agent       = require('models/agent');
const Rule        = require('models/rule');
const Trait       = require('models/trait');
const Interactive = require('ui/interactive');
const Events      = require('events');
const ToolButton  = require('ui/tool-button');
const BasicAnimal = require('models/agents/basic-animal');

const plantSpecies  = require('species/fast-plants-roots');
const rabbitSpecies = require('species/white-brown-rabbits');
const hawkSpecies   = require('species/hawks');
const env           = require('environments/snow');

window.model = {
  brownness: 0,
  run() {
    this.interactive = new Interactive({
      environment: env,
      speedSlider: true,
      addOrganismButtons: [
        {
          species: plantSpecies,
          imagePath: "images/agents/grass/tallgrass.png",
          traits: [          ],
          limit: 180,
          scatter: 45
        },
        {
          species: rabbitSpecies,
          imagePath: "images/agents/rabbits/rabbit2.png",
          traits: [
            new Trait({name: "mating desire bonus", default: -20}),
            new Trait({name: "hunger bonus", default: -10}),
            new Trait({name: "age", default: 3}),
            new Trait({name: "resource consumption rate", default: 10})
          ],
          limit: 30,
          scatter: 30
        },
        {
          species: hawkSpecies,
          imagePath: "images/agents/hawks/hawk.png",
          traits: [
            new Trait({name: "mating desire bonus", default: -10})
          ],
          limit: 2,
          scatter: 2
        }
      ],
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
      ]});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.env = env;
    this.plantSpecies = plantSpecies;
    this.hawkSpecies = hawkSpecies;
    this.rabbitSpecies = rabbitSpecies;

    return env.addRule(new Rule({
      action: agent => {
        if (agent.species === rabbitSpecies) {
          if (agent.get('color') === 'brown') {
            return agent.set('chance of being seen', (0.6 - (this.brownness*0.6)));
          } else {
            return agent.set('chance of being seen', (this.brownness*0.6));
          }
        }
      }
    })
    );
  },

  setupGraph() {
    const outputOptions = {
      title:  "Number of rabbits",
      xlabel: "Time (s)",
      ylabel: "Number of rabbits",
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
      sampleInterval: (Environment.DEFAULT_RUN_LOOP_DELAY/1000),
      dataType: 'samples',
      dataColors: [
        "#999999",
        "#995500",
        "#F00"
      ]
    };

    this.outputGraph = LabGrapher('#graph', outputOptions);

    Events.addEventListener(Environment.EVENTS.RESET, () => {
      return this.outputGraph.reset();
    });

    return Events.addEventListener(Environment.EVENTS.STEP, () => {
      return this.outputGraph.addSamples(this.countRabbits());
    });
  },

  agentsOfSpecies(species){
    const set = [];
    for (let a of Array.from(this.env.agents)) {
      if (a.species === species) { set.push(a); }
    }
    return set;
  },

  countRabbits() {
    let whiteRabbits = 0;
    let brownRabbits = 0;
    for (let a of Array.from(this.agentsOfSpecies(this.rabbitSpecies))) {
      if (a.get('color') === 'white') { whiteRabbits++; }
      if (a.get('color') === 'brown') { brownRabbits++; }
    }
    return [whiteRabbits, brownRabbits];
  },

  setupTimer() {
    let backgroundChangeable = false;
    const changeInterval = 10;
    Events.addEventListener(Environment.EVENTS.STEP, () => {
      const t = Math.floor((this.env.date * Environment.DEFAULT_RUN_LOOP_DELAY) / 1000); // this will calculate seconds at default speed
      if (t > 99) {
        this.env.stop();
        this.showMessage("All the snow is gone. Look at the graph.<br/>How many white and brown rabbits are left in the field?");
        return;
      }

      if (((t % changeInterval) === 0) && backgroundChangeable && ((t/changeInterval) <= 9)) {
        this.brownness = (0.1 * t)/changeInterval;
        this.changeBackground(t/changeInterval);
        return backgroundChangeable = false;
      } else if ((t % changeInterval) !== 0) {
        return backgroundChangeable = true;
      }
    });

    return Events.addEventListener(Environment.EVENTS.RESET, () => {
      return this.env.setBackground("images/environments/snow.png");
    });
  },

  changeBackground(n){
    if (!(0 < n && n < 10)) { return; }
    return this.env.setBackground(`images/environments/snow-${n}.png`);
  },

  showMessage(message, callback) {
    return helpers.showMessage(message, this.env.getView().view.parentElement, callback);
  },

  setupPopulationControls() {
    return Events.addEventListener(Environment.EVENTS.STEP, () => {
      this.checkPlants();
      this.checkRabbits();
      return this.checkHawks();
    });
  },

  setProperty(agents, prop, val){
    return Array.from(agents).map((a) =>
      a.set(prop, val));
  },

  addAgent(species, properties){
    if (properties == null) { properties = []; }
    const agent = species.createAgent();
    agent.setLocation(this.env.randomLocation());
    for (let prop of Array.from(properties)) {
      agent.set(prop[0], prop[1]);
    }
    return this.env.addAgent(agent);
  },


  addedRabbits: false,
  addedHawks: false,
  numRabbits: 0,
  checkRabbits() {
    const allRabbits = this.agentsOfSpecies(this.rabbitSpecies);
    const allPlants  = this.agentsOfSpecies(this.plantSpecies);

    this.numRabbits = allRabbits.length;

    if (this.numRabbits === 0) {
      if (this.addedRabbits && !this.addedHawks) {
        this.env.stop();
        this.showMessage("Uh oh, all the rabbits have died!<br/>Did you add any plants? Reset the model and try it again.");
        return;
      }
    }
    const numPlants = allPlants.length;

    if (!this.addedRabbits && (this.numRabbits > 0)) {
      this.addedRabbits = true;
    }

    if (this.addedRabbits && (numPlants > 0) && (this.numRabbits < 9)) {
      this.addAgent(this.rabbitSpecies, [["resource consumption rate", 10]]);
      this.addAgent(this.rabbitSpecies, [["resource consumption rate", 10]]);
      // faking here
      const color = this.brownness > 0.5 ? "brown" : "white";
      this.addAgent(this.rabbitSpecies, [["resource consumption rate", 10],["color", color]]);
      this.addAgent(this.rabbitSpecies, [["resource consumption rate", 10],["color", color]]);
    }

    if (this.numRabbits < 16) {
      this.setProperty(allRabbits, "min offspring", 2);
      this.setProperty(allRabbits, "speed", 70);
    } else {
      // @setProperty(allRabbits, "metabolism", 1)
      this.setProperty(allRabbits, "mating desire bonus", -20);
      this.setProperty(allRabbits, "hunger bonus", -10);
      this.setProperty(allRabbits, "min offspring", 1);
      this.setProperty(allRabbits, "speed", 50);
    }

    if (this.numRabbits > 50) {
      return this.setProperty(allRabbits, "mating desire bonus", -40);
    }
  },

  checkHawks() {
    const allHawks = this.agentsOfSpecies(this.hawkSpecies);
    const numHawks = allHawks.length;

    if (numHawks === 0) {
      if (this.addedHawks) {
        if (this.addedRabbits) {
          this.env.stop();
          this.showMessage("Uh oh, all the animals have died!<br/>Was there any food for the rabbits to eat? Reset the model and try it again.");
        } else {
          this.env.stop();
          this.showMessage("Uh oh, all the hawks have died!<br/>Were there any rabbits for them to eat? Reset the model and try it again.");
        }
      }
      return;
    }

    if (!this.addedHawks && (numHawks > 0)) {
      this.addedHawks = true;
    }

    if (this.addedHawks && (this.numRabbits > 0) && (numHawks < 2)) {
      this.addAgent(this.hawkSpecies);
    }

    if ((numHawks < 3) && (this.numRabbits > 0)) {
      this.setProperty(allHawks, "is immortal", true);
      this.setProperty(allHawks, "mating desire bonus", -10);
      return this.setProperty(allHawks, "hunger bonus", 5);
    } else {
      if (allHawks[0].get("is immortal")) {
        this.setProperty(allHawks, "is immortal", false);
      }

      if (numHawks > 4) {
        this.setProperty(allHawks, "mating desire bonus", -30);
        return this.setProperty(allHawks, "hunger bonus", -40);
      } else {
        this.setProperty(allHawks, "mating desire bonus", -15);
        return this.setProperty(allHawks, "hunger bonus", -5);
      }
    }
  },

  checkPlants() {
    const allPlants  = this.agentsOfSpecies(this.plantSpecies);
    if (allPlants.length < 100) {
      return this.setProperty(allPlants, 'growth rate', 0.007);
    } else if (allPlants.length < 300) {
      return this.setProperty(allPlants, 'growth rate', 0.0035);
    } else {
      return this.setProperty(allPlants, 'growth rate', 0.0005);
    }
  },

  preload: [
    "images/agents/grass/tallgrass.png",
    "images/agents/rabbits/rabbit2.png",
    "images/agents/hawks/hawk.png",
    "images/environments/snow.png",
    "images/environments/snow-1.png",
    "images/environments/snow-2.png",
    "images/environments/snow-3.png",
    "images/environments/snow-4.png",
    "images/environments/snow-5.png",
    "images/environments/snow-6.png",
    "images/environments/snow-7.png",
    "images/environments/snow-8.png",
    "images/environments/snow-9.png"
  ]
};

window.onload = () =>
  helpers.preload([model, env, plantSpecies, rabbitSpecies, hawkSpecies], function() {
    model.run();
    model.setupGraph();
    model.setupTimer();
    return model.setupPopulationControls();
  })
;
