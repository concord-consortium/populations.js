// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const foxSpecies  = window.FoxSpecies;

window.model = {
  run() {
    this.interactive = new Populations.Interactive({
      environment: env,
      speedSlider: false,
      addOrganismButtons: [
        {
          species: foxSpecies,
          scatter: 1,
          imagePath: "images/agents/foxes/fox.png"
        }
      ],
      toolButtons: [
        {
          type: Populations.ToolButton.INFO_TOOL
        }
      ]});

    return document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());
  }
};

window.onload = () =>
  Populations.helpers.preload([model, env, foxSpecies], () => model.run())
;
