const plantSpecies  = window.FastPlantsRootsSpecies;
const rabbitSpecies = window.WhiteBrownRabbitsSpecies;

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
          scatter: 400
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
            new Populations.Trait({name: "metabolism", default: 1})
          ],
          limit: 700,
          scatter: 70
        }
      ],
      toolButtons: [
        {
          type: Populations.ToolButton.INFO_TOOL
        }
      ]});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.interactive.setEnvironmentDisplayWidth(600);

    this.interactive.addMouseListener((evt) => {
      document.getElementById('event-type').innerHTML = evt.type;
      document.getElementById('event-x').innerHTML = Math.round(evt.envX);
      document.getElementById('event-y').innerHTML = Math.round(evt.envY);
    });

    this.interactive.addAgentMouseListener((evt) => {
      if (evt.agents.rabbits) {
        document.getElementById('event-rabbit-age').innerHTML = evt.agents.rabbits.get("age");
      } else {
        document.getElementById('event-rabbit-age').innerHTML = "";
      }

      if (evt.agents["fast plants"]) {
        document.getElementById('event-plant-age').innerHTML = evt.agents["fast plants"].get("age");
      } else {
        document.getElementById('event-plant-age').innerHTML = "";
      }
    });
  },

  preload: [
    "images/agents/grass/tallgrass.png",
    "images/agents/rabbits/rabbit2.png"
  ]
};

window.onload = () =>
  Populations.helpers.preload([model, env, plantSpecies, rabbitSpecies], function() {
    model.run();
  })
;