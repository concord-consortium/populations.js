// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const helpers     = require('helpers');

const Interactive = require('ui/interactive');
const ToolButton  = require('ui/tool-button');

const foxSpecies  = require('species/animated-foxes');
const env         = require('environments/open');

window.model = {
  run() {
    this.interactive = new Interactive({
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
          type: ToolButton.INFO_TOOL
        }
      ]});

    return document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());
  }
};

window.onload = () =>
  helpers.preload([model, env, foxSpecies], () => model.run())
;
