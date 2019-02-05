// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

const mouseSpecies  = window.MouseSpecies;

window.model = {
  run() {
    env.imgPath = "images/environments/mixed.png";
    this.interactive = new Populations.Interactive({
      environment: env,
      speedSlider: false,
      addOrganismButtons: [
        {
          species: mouseSpecies,
          scatter: 1,
          imagePath: "images/agents/mice/mouse.png"
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
  Populations.helpers.preload([model, env, mouseSpecies], () => model.run())
;
