// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

window.model2 = {
  run() {
    const interactive = new Populations.Interactive({
      environment: env2,
      showToolbar: false,
      addOrganismButtons: [
        {
          species: FastPlantsRootsSpecies,
          imagePath: "images/agents/grass/tallgrass.png",
          traits: [          ],
          limit: 180,
          scatter: 65
        },
        {
          species: WhiteBrownRabbitsSpecies,
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

    document.getElementById('interactive-2').appendChild(interactive.getEnvironmentPane());
    window.interactive2 = interactive;
  }
};

window.onload = () =>
  Populations.helpers.preload([model, env2, FastPlantsRootsSpecies, WhiteBrownRabbitsSpecies], function() {
    model.run();
    model2.run();
  });
;
