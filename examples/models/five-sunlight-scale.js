// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const plantSpecies = window.VariedPlantsSpecies;

window.model = {
  displayWidth: 200,

  run() {
    plantSpecies.defs.CAN_SEED = false;

    this.interactive = new Populations.Interactive({
      environment: env,
      addOrganismButtons: [
        {
          species: plantSpecies,
          imagePath: "images/agents/varied-plants/buttons/seedpack_10.png",
          traits: [
            new Populations.Trait({name: "size", default: 1}),
            new Populations.Trait({name: "root size", default: 5})
          ],
          limit: 20
        }
      ],
      toolButtons: [
        {
          type: Populations.ToolButton.INFO_TOOL
        }
      ]});

    document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());

    this.interactive.setEnvironmentDisplayWidth(this.displayWidth);
  },

  preload: [
    "images/agents/varied-plants/buttons/seedpack_10.png"
  ]
};

window.onload = () =>
  Populations.helpers.preload([model, env, plantSpecies], () => model.run())
;

window.tiny = () => {
  model.displayWidth = 60;
  model.interactive.setEnvironmentDisplayWidth(model.displayWidth);
}

window.big = () => {
  model.displayWidth = 800;
  model.interactive.setEnvironmentDisplayWidth(model.displayWidth);
}

// inexact, because of toolbar buttons
window.fit = () => {
  const maxWidth = window.innerWidth - 50; // toolbar
  const maxHeight = window.innerHeight - 30; // buttons
  model.interactive.constrain(maxWidth, maxHeight);
}
