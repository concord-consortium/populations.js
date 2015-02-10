// Generated by CoffeeScript 1.7.1
(function() {
  var Interactive, ToolButton, env, foxSpecies, helpers;

  helpers = require('helpers');

  Interactive = require('ui/interactive');

  ToolButton = require('ui/tool-button');

  foxSpecies = require('species/animated-foxes');

  env = require('environments/open');

  window.model = {
    run: function() {
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
        ]
      });
      return document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());
    }
  };

  window.onload = function() {
    return helpers.preload([model, env, foxSpecies], function() {
      return model.run();
    });
  };

}).call(this);