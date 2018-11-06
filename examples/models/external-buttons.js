// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const plantSpecies  = FastPlantsRootsSpecies;
const rabbitSpecies = WhiteBrownRabbitsSpecies;

window.model = {
  run() {
    console.log("run!");
    const interactive = new Populations.Interactive({
      environment: env,
      showToolbar: false,
      addOrganismButtons: [
        {
          species: plantSpecies,
          imagePath: "images/agents/grass/tallgrass.png",
          traits: [          ],
          limit: 180,
          scatter: 65
        },
        {
          species: rabbitSpecies,
          imagePath: "images/agents/rabbits/rabbit2.png",
          traits: [
            new Populations.Trait({name: "mating desire bonus", default: -20}),
            new Populations.Trait({name: "hunger bonus", default: -10}),
            new Populations.Trait({name: "age", default: 3}),
            new Populations.Trait({name: "resource consumption rate", default: 5})
          ],
          limit: 40,
          scatter: 20
        }
      ],
      toolButtons: [
        {
          type: Populations.ToolButton.INFO_TOOL
        }
      ]});

    document.getElementById('environment').appendChild(interactive.getEnvironmentPane());
    window.interactive = interactive;
  }
};

window.onload = () =>
  Populations.helpers.preload([model, env, plantSpecies, rabbitSpecies], function() {
    model.run();
  });
;
