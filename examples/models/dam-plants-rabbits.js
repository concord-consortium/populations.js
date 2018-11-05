// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS202: Simplify dynamic range loops
 * DS205: Consider reworking code to avoid use of IIFEs
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
const rabbitSpecies = require('species/varied-rabbits');
const env           = require('environments/dam');

window.model = {
  showMessage(message, callback) {
    return helpers.showMessage(message, this.env.getView().view.parentElement, callback);
  },

  run() {
    this.interactive = new Interactive({
      environment: env,
      speedSlider: false,
      addOrganismButtons: [
        {
          species: plantSpecies,
          imagePath: "images/agents/grass/medgrass.png",
          traits: [
            new Trait({name: "population size modifier", default: 0.0, float: true}),
            new Trait({name: "roots", possibleValues: [1,2,3] })
          ],
          limit: 140,
          scatter: 140
        },
        {
          species: rabbitSpecies,
          imagePath: "images/agents/rabbits/smallbunny.png",
          traits: [
            new Trait({name: "age", default: 3})
          ],
          limit: 40,
          scatter: 40
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
    this.rabbitSpecies = rabbitSpecies;

    this._reset();
    return Events.addEventListener(Environment.EVENTS.RESET, () => {
      return this._reset();
    });
  },

  _reset() {
    this.env.setBackground("images/environments/dam-year0.png");
    this._setEnvironmentProperty('water', 10);
    this.damCreated = false;
    return this._setEnvironmentProperty('water', 10, true);
  },

  chartData1: null,
  chartData2: null,
  chart1: null,
  chart2: null,
  setupCharts() {
    // setup chart data
    this.chartData1 = new google.visualization.DataTable();
    this.chartData2 = new google.visualization.DataTable();
    this._setupChartData(this.chartData1);
    this._setupChartData(this.chartData2);

    // Instantiate and draw our chart, passing in some options.
    const options1 = this._getChartOptions("top");
    const options2 = this._getChartOptions("bottom");
    this.chart1 = new google.visualization.ColumnChart(document.getElementById('chart1'));
    this.chart2 = new google.visualization.ColumnChart(document.getElementById('chart2'));
    this.chart1.draw(this.chartData1, options1);
    this.chart2.draw(this.chartData2, options2);

    return Events.addEventListener(Environment.EVENTS.STEP, () => {
      const counts = {
        top: [0,0,0,0],
        bottom: [0,0,0,0]
      };

      for (let agent of Array.from(this.env.agents)) {
        if (agent.species === this.rabbitSpecies) {
          if (agent.getLocation().y < ((this.env.rows * this.env._rowHeight)/2)) {
            counts.top[agent.get('size')] += 1;
          } else {
            counts.bottom[agent.get('size')] += 1;
          }
        }
      }

      for (let i = 0; i <= 2; i++) {
        this.chartData1.setValue(i, 1, counts.top[i+1]);
        this.chartData2.setValue(i, 1, counts.bottom[i+1]);
      }

      // if counts[1] > 10 or counts[5] > 10 or counts[9] > 10
      //   options.vAxis.gridlines.count = -1

      this.chart1.draw(this.chartData1, options1);
      return this.chart2.draw(this.chartData2, options2);
    });
  },

  _setupChartData(chartData){
    chartData.addColumn('string', 'Rabbit types');
    chartData.addColumn('number', 'Number of rabbits');
    chartData.addColumn({ type: 'string', role: 'style' });
    return chartData.addRows([
      ["Small",  0, "color: #FF0000"],
      ["Medium", 0, "color: #FF0000"],
      ["Big",    0, "color: #FF0000"]
    ]);
  },

  _getChartOptions(titleMod){
    // Set chart options
    let options;
    return options = {
      title: `Rabbits in ${titleMod} half of the field`,
      hAxis: {
        title: 'Rabbit types'
      },
      vAxis: {
        title: 'Number of rabbits',
        minValue: 0,
        maxValue: 50,
        gridlines: {
          count: 6
        }
      },
      legend: {
        position: 'none'
      },
      width: 300,
      height: 250
    };
  },

  _agentsOfSpecies(species){
    const set = [];
    for (let a of Array.from(this.env.agents)) {
      if (a.species === species) { set.push(a); }
    }
    return set;
  },

  damCreated: false,
  setupControls() {
    const createDamButton = document.getElementById('build-button');
    createDamButton.onclick = () => {
      if (!this.damCreated) {
        this.damCreated = true;
        // fast-forward to the beginning of the first year
        return this.env.date = Math.floor(10000/Environment.DEFAULT_RUN_LOOP_DELAY)-1;
      }
    };

    const noneHighlightRadio = document.getElementById('highlight-none');
    const smallHighlightRadio = document.getElementById('highlight-small');
    const mediumHighlightRadio = document.getElementById('highlight-medium');
    const bigHighlightRadio = document.getElementById('highlight-big');

    noneHighlightRadio.onclick = () => {
      return this._highlight(-1);
    };
    smallHighlightRadio.onclick = () => {
      return this._highlight(1);
    };
    mediumHighlightRadio.onclick = () => {
      return this._highlight(2);
    };
    bigHighlightRadio.onclick = () => {
      return this._highlight(3);
    };

    return Events.addEventListener(Environment.EVENTS.RESET, () => noneHighlightRadio.click());
  },

  _highlight(size){
    return (() => {
      const result = [];
      for (let agent of Array.from(this.env.agents)) {
        if (agent.species === this.rabbitSpecies) {
          result.push(agent.set('glow', (agent.get('size') === size)));
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  },

  setupTimer() {
    let backgroundChangeable = false;
    const changeInterval = 10;
    let waterLevel = 10;
    const yearSpan = document.getElementById('year');
    const waterLevelIndicator = document.getElementById('water-level-indicator');
    Events.addEventListener(Environment.EVENTS.STEP, () => {
      if (!this.damCreated) {
        // time doesn't pass until the dam is built
        this.env.date = 0;
        return;
      }
      const t = Math.floor((this.env.date * Environment.DEFAULT_RUN_LOOP_DELAY) / 1000); // this will calculate seconds at default speed

      const year = t/changeInterval;
      waterLevel = 11-Math.min(11, year);
      const waterLevelPct = waterLevel*10;
      this._setEnvironmentProperty('water', waterLevel);
      // Update vertical bar level indicator in page
      waterLevelIndicator.style.height = `${waterLevelPct}%`;
      if (((t % changeInterval) === 0) && backgroundChangeable) {
        this._changeBackground(year);
        yearSpan.innerHTML = `${year}`;
        return backgroundChangeable = false;
      } else if ((t % changeInterval) !== 0) {
        return backgroundChangeable = true;
      }
    });

    return Events.addEventListener(Environment.EVENTS.RESET, function() {
      backgroundChangeable = false;
      yearSpan.innerHTML = "1";
      return waterLevelIndicator.style.height = "100%";
    });
  },

  _changeBackground(n){
    if (!(0 < n && n < 11)) { return; }
    return this.env.setBackground(`images/environments/dam-year${n}.png`);
  },

  _setAgentProperty(agents, prop, val){
    return Array.from(agents).map((a) =>
      a.set(prop, val));
  },

  _setEnvironmentProperty(prop, val, all){
    if (all == null) { all = false; }
    return (() => {
      const result = [];
      for (var row = 0, end = this.env.rows, asc = 0 <= end; asc ? row <= end : row >= end; asc ? row++ : row--) {
        if (all || (row > (this.env.rows/2))) {
          result.push(__range__(0, (this.env.columns), true).map((col) =>
            this.env.set(col, row, prop, val)));
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  },

  _addAgent(species, properties){
    if (properties == null) { properties = []; }
    const agent = species.createAgent();
    agent.setLocation(this.env.randomLocation());
    for (let prop of Array.from(properties)) {
      agent.set(prop[0], prop[1]);
    }
    return this.env.addAgent(agent);
  },

  setupPopulationMonitoring() {
    return Events.addEventListener(Environment.EVENTS.STEP, () => {
      // Check population levels and adjust accordingly
      this._setPlantGrowthRate();
      this._setRabbitGrowthRate();
      if (Math.random() < 0.1) {
        return this._makeLandFertile();
      }
    });
  },


  _plantsExist: false,
  _setPlantGrowthRate() {
    const allPlants = this._agentsOfSpecies(this.plantSpecies);
    if (allPlants.length < 1) {
      this._plantsExist = false;
      return;
    } else {
      this._plantsExist = true;
    }

    const varieties = [[], [], [], [], [], []];
    for (let plant of Array.from(allPlants)) {
      const rootSize = plant.get("roots");
      const adder = plant.getLocation().y > 250 ? 3 : 0;
      varieties[((rootSize - 1) + adder)].push(plant);
    }

    return Array.from(varieties).map((variety) =>
      this._setGrowthRateForVariety(variety));
  },

  _setRabbitGrowthRate() {
    const allRabbits = this._agentsOfSpecies(this.rabbitSpecies);
    const varieties = [[], [], [], [], [], []];
    for (let rabbit of Array.from(allRabbits)) {
      const rabbitSize = rabbit.get("size");
      const adder = rabbit.getLocation().y > 250 ? 3 : 0;
      varieties[((rabbitSize - 1) + adder)].push(rabbit);
    }

    return Array.from(varieties).map((variety) =>
      this._dontLetRabbitsDie(variety));
  },

  _setGrowthRateForVariety(plants){
    const plantSize = plants.length;
    let populationSizeModifier = 0.0;
    if (plantSize < 10) {
      populationSizeModifier = 0.7;
    } else if (plantSize < 15) {
      populationSizeModifier = 0.4;
    } else if (plantSize < 40) {
      populationSizeModifier = 0.1;
    } else if (plantSize < 60) {
      populationSizeModifier = 0.0;
    } else if (plantSize < 160) {
      populationSizeModifier = -0.02;
    } else if (plantSize < 190) {
      populationSizeModifier = -0.03;
    } else if (plantSize < 230) {
      populationSizeModifier = -0.05;
    } else {
      let i = plantSize-1;
      while (i > 0) {
        plants[i].die();
        i -= 5;
      }
    }

    return Array.from(plants).map((plant) =>
      plant.set("population size modifier", populationSizeModifier));
  },

  _dontLetRabbitsDie(rabbits){
    const rabbitsSize = rabbits.length;
    let maxOffspring = 6;
    let matingDistance = 90;
    let resourceConsumptionRate = 15;
    let metabolism = 2;
    let isImmortal = false;

    if ((rabbitsSize < 3) && (rabbitsSize > 0) && (rabbits[0].get("size") === 3) && this._plantsExist) {
      maxOffspring = 12;
      matingDistance = 250;
      resourceConsumptionRate = 0;
      metabolism = 1;
      const age = 30;
      isImmortal = true;
    } else if ((rabbitsSize < 4) && (rabbitsSize > 0) && (rabbits[0].get("size") === 3) && this._plantsExist) {
      maxOffspring = 10;
      matingDistance = 170;
      resourceConsumptionRate = 1;
      metabolism = 1;
    } else if ((rabbitsSize < 5) && (rabbitsSize > 0) && (rabbits[0].get("size") === 3)) {
      maxOffspring = 9;
      matingDistance = 160;
      resourceConsumptionRate = 4;
      metabolism = 1;
    } else if (rabbitsSize < 6) {
      maxOffspring = 8;
      matingDistance = 140;
      resourceConsumptionRate = 5;
      metabolism = 1;
    } else if (rabbitsSize < 7) {
      maxOffspring = 7;
      matingDistance = 130;
      resourceConsumptionRate = 8;
      metabolism = 2;
    } else if (rabbitsSize < 20) {
    } else if (rabbitsSize < 25) {
      maxOffspring = 5;
      matingDistance = 80;
      resourceConsumptionRate = 16;
      metabolism = 3;
    } else if (rabbitsSize < 35) {
      maxOffspring = 2;
      matingDistance = 80;
      resourceConsumptionRate = 18;
      metabolism = 5;
    } else {
      maxOffspring = 0;
      resourceConsumptionRate = 18;
      metabolism = 9;
    }

    return (() => {
      const result = [];
      for (let rabbit of Array.from(rabbits)) {
        rabbit.set("max offspring", maxOffspring);
        rabbit.set("mating distance", matingDistance);
        rabbit.set("resource consumption rate", resourceConsumptionRate);
        rabbit.set("metabolism", metabolism);
        result.push(rabbit.set("is immortal", isImmortal));
      }
      return result;
    })();
  },

  _makeLandFertile() {
    // TODO Implment this!
    // env.replenishResources()
  },
    // FIXME What does this do?
    // allPlants = @_agentsOfSpecies @plantSpecies
    // for plant in allPlants
    //   loc = plant.getLocation()
    //   if loc.y > 228 && loc.y < 260
    //     plant.die()

  preload: [
    "images/agents/grass/medgrass.png",
    "images/agents/rabbits/smallbunny.png",
    "images/environments/dam-year0.png",
    "images/environments/dam-year1.png",
    "images/environments/dam-year2.png",
    "images/environments/dam-year3.png",
    "images/environments/dam-year4.png",
    "images/environments/dam-year5.png",
    "images/environments/dam-year6.png",
    "images/environments/dam-year7.png",
    "images/environments/dam-year8.png",
    "images/environments/dam-year9.png",
    "images/environments/dam-year10.png"
  ]
};

window.onload = () =>
  helpers.preload([model, env, rabbitSpecies, plantSpecies], function() {
    model.run();
    model.setupControls();
    model.setupCharts();
    model.setupTimer();
    return model.setupPopulationMonitoring();
  })
;

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}