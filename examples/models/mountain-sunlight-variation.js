// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const plantSpecies = window.VariedPlantsSpecies;

window.model = {
  emptyBarriers: [
    [  0,   0,  39, 520],
    [561,   0,  39, 520]
  ],
  mountainBarriers: [
    [  0,   0,  39, 520],
    [561,   0,  39, 520],
    [140, 490,  25,  30],
    [165, 450,  25,  70],
    [190, 300,  30, 220],
    [220, 150,  40, 370],
    [260,  70,  25, 450],
    [285,   0,  50, 520],
    [335,   0,  25, 490],
    [360,   0,  25, 335],
    [385,   0,  20, 260],
    [405,   0,  20, 160]
  ],
  run() {
    plantSpecies.defs.CHANCE_OF_MUTATION = 0.21;
    plantSpecies.setMutatable('root size', false);

    this.interactive = new Populations.Interactive({
      environment: env,
      speedSlider: true,
      addOrganismButtons: [
        {
          scatter: 8,
          limit: 40,
          species: plantSpecies,
          imagePath: "images/agents/varied-plants/buttons/seedpack_6.png",
          traits: [
            new Populations.Trait({name: "size", default: 5}),
            new Populations.Trait({name: "root size", default: 5})
          ]
        }
      ],
      toolButtons: [
        {
          type: Populations.ToolButton.INFO_TOOL
        }
      ]});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.env = env;
    return this.plantSpecies = plantSpecies;
  },

  setupMountains() {
    const mountains1 = document.getElementById('mountains1');
    const mountains2 = document.getElementById('mountains2');
    const mountains3 = document.getElementById('mountains3');
    const mountains4 = document.getElementById('mountains4');
    const mountains5 = document.getElementById('mountains5');

    mountains1.onclick = () => {
      return this._updateMountains("images/environments/mountains1.jpg", this.emptyBarriers, 6, 6);
    };
    mountains2.onclick = () => {
      return this._updateMountains("images/environments/mountains2flipped.jpg", this.mountainBarriers, 7, 5);
    };
    mountains3.onclick = () => {
      return this._updateMountains("images/environments/mountains3flipped.jpg", this.mountainBarriers, 8, 4);
    };
    mountains4.onclick = () => {
      return this._updateMountains("images/environments/mountains4flipped.jpg", this.mountainBarriers, 9, 3);
    };
    mountains5.onclick = () => {
      return this._updateMountains("images/environments/mountains5flipped.jpg", this.mountainBarriers, 10, 2);
    };

    return Populations.Events.addEventListener(Populations.Environment.EVENTS.RESET, () => mountains1.click());
  },

  _updateMountains(imgPath, barriers, leftSunlight, rightSunlight){
    this.env.setBackground(imgPath);
    this.env.setBarriers(barriers);
    for (let col = 0; col < 60; col++) {
      const light = col > 30 ? rightSunlight : leftSunlight;
      for (let row = 0; row < 52; row++) {
        this.env.set(col, row, "sunlight", light);
      }
    }

    return (() => {
      const result = [];
      for (let agent of Array.from(this.env.agents)) {
        const loc = agent.getLocation();
        if (this.env.isInBarrier(loc.x, loc.y)) {
          result.push(agent.die());
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  },

  showMessage(message, callback) {
    return Populations.helpers.showMessage(message, this.env.getView().view.parentElement, callback);
  },

  setupMessages() {
    let extinctionCount = 0; // this does NOT reset between runs
    let successful = false;  // this does NOT reset between runs
    let userAddedAgents = false;
    let yearsSuccessful = 0; // don't win until final plants liev at least one year
    let shownMessage = false;
    let allAgents = [];

    Populations.Events.addEventListener(Populations.Environment.EVENTS.RESET, function() {
      userAddedAgents = false;
      yearsSuccessful = 0; // don't win until final plants liev at least one year
      shownMessage = false;
      return allAgents = [];
  });

    Populations.Events.addEventListener(Populations.Environment.EVENTS.AGENT_ADDED, () => userAddedAgents = true);

    return Populations.Events.addEventListener(Populations.Environment.EVENTS.SEASON_CHANGED, evt=> {
      if (!shownMessage) {
        let mountainHeight;
        if ((evt.detail.season === "winter") || (evt.detail.season === "spring")) {
          return;   // don't check on winter or spring, because it's hard for user to see what's happening
        }
        allAgents = this.env.agents;
        let allExtinct = false;
        let halfExtinct = false;
        let willAnyoneSurvive = false;  // if half extinct but no one will survive (all wilted) wait until all are extinct
        if (allAgents.length === 0) {
          allExtinct = true;
        } else {
          const sunlightTopLeft = this.env.get(0,0,"sunlight");
          mountainHeight = sunlightTopLeft - 6;
          if (mountainHeight === 0) {
            return;
          }
          halfExtinct = this._getSideIsExtinct();
          if (halfExtinct) {
            willAnyoneSurvive = this._getWillAnyoneSurvive();
          }
        }
        if (allExtinct || halfExtinct) {
          if (successful && (allExtinct || willAnyoneSurvive)) {
            // case 2
            this.showMessage("The plants went extinct. Why did the plants go\nextinct when the mountains changed quickly?");
            env.stop();
            extinctionCount++;
          } else if (extinctionCount === 0) {
            // case 1, first time
            if (allExtinct) {
              this.showMessage("Your plants went extinct. Click reset and try again.");
              env.stop();
              extinctionCount++;
            } else if (willAnyoneSurvive) {
              this.showMessage("Your plants went extinct on one side. Remember, the challenge is to have flowering plants\ngrowing on both sides of the mountains. Click reset and try again.");
              env.stop();
              extinctionCount++;
            }
          } else {
            // case 1, next times
            if (allExtinct) {
              this.showMessage("Your plants went extinct again. The environment changed too quickly.\nWait a few seasons before you change the mountain height.");
              env.stop();
              extinctionCount++;
            } else if (willAnyoneSurvive) {
              this.showMessage("Half your plants went extinct again. The environment changed too quickly.\nWait a few seasons before you change the mountain height.");
              env.stop();
              extinctionCount++;
            }
          }
          shownMessage = true;
          return;
        }
        // not extinct
        if (mountainHeight === 4) {
          // end
          if (evt.detail.season === "fall") {
            // only end on fall so we can see flowers
            if (this._atLeastTenPlantsHealthyOnBothSides()) {
              yearsSuccessful++;
              if (yearsSuccessful > 1) {
                successful = true;
                if (extinctionCount > 0) {
                  // case 1 success
                  this.showMessage("Great job! The mountains grew slowly enough so that the plants could evolve.\nTake a Snapshot to help answer the question.");
                  env.stop();
                  return shownMessage = true;
                } else {
                  // case 2 success
                  this.showMessage("Congratulations! The mountains grew slowly and the plants had time to evolve.\n Take a Snapshot to help answer the question.\nThen click reset and try changing the environment quickly. What do you think will happen?");
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

  _getSideIsExtinct() {
    let eastAlive = false;
    let westAlive = false;
    for (let agent of Array.from(this.env.agents)) {
      const { x } = agent.getLocation();
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

  _getWillAnyoneSurvive() {
    for (let agent of Array.from(this.env.agents)) {
      const healthy = agent.get("health") > 0.99;
      if (healthy) {
        return true;
      }
    }
    return false;
  },

  _atLeastTenPlantsHealthyOnBothSides() {
    let eastHealthyCount = 0;
    let westHealthyCount = 0;
    for (let agent of Array.from(this.env.agents)) {
      if ((agent.get("health") > 0.99) && !agent.get("is seed")) {
        const { x } = agent.getLocation();
        if (x < ((this.env.columns / 2) * this.env._columnWidth)) {
          eastHealthyCount++;
        } else {
          westHealthyCount++;
        }
      }
      if ((eastHealthyCount >= 10) && (westHealthyCount >= 10)) {
        return true;
      }
    }
    return false;
  },

  chartData: null,
  chart: null,
  setupChart() {
    const domChart = document.getElementById('chart');

    if (domChart != null) {
      const toggleButton = document.getElementById('chart-visibility');
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

      // init chart
      this.chartData = new google.visualization.DataTable();
      this.chartData.addColumn('string', 'Plant Type (Leaf Size)');
      this.chartData.addColumn('number', 'Number of plants');
      this.chartData.addColumn({ type: 'string', role: 'style' });
      this.chartData.addRows([
        ["1",  0, "color: #5942BF"],
        ["2",  0, "color: #5F42B8"],
        ["3",  0, "color: #65429F"],
        ["4",  0, "color: #73419E"],
        ["5",  0, "color: #874084"],
        ["6",  0, "color: #904078"],
        ["7",  0, "color: #9F416B"],
        ["8",  0, "color: #B5435A"],
        ["9",  0, "color: #C84349"],
        ["10", 0, "color: #D34441"]
      ]);

      // Set chart options
      const options = {
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

      // Instantiate and draw our chart, passing in some options.
      this.chart = new google.visualization.ColumnChart(domChart);
      this.chart.draw(this.chartData, options);

      return Populations.Events.addEventListener(Populations.Environment.EVENTS.STEP, () => {
        let i;
        if (this.env.get(0, 0, "season") !== "summer") { return; }
        const counts = []; for (i = 0; i <= 9; i++) { counts.push(0); }
        for (let agent of Array.from(this.env.agents)) {
          if (agent.get('has flowers')) { counts[agent.get('size')] += 1; }
        }

        for (i = 0; i <= 8; i++) {
          this.chartData.setValue(i, 1, counts[i+1]);
        }

        if ((counts[1] > 10) || (counts[5] > 10) || (counts[9] > 10)) {
          options.vAxis.gridlines.count = -1;
        }

        return this.chart.draw(this.chartData, options);
      });
    }
  },

  preload: [
    "images/agents/varied-plants/buttons/seedpack_10.png",
    "images/environments/mountains1.jpg",
    "images/environments/mountains2flipped.jpg",
    "images/environments/mountains3flipped.jpg",
    "images/environments/mountains4flipped.jpg",
    "images/environments/mountains5flipped.jpg"
  ]
};

window.onload = () =>
  Populations.helpers.preload([model, env, plantSpecies], function() {
    model.run();
    model.setupMountains();
    model.setupMessages();
    return model.setupChart();
  })
;
