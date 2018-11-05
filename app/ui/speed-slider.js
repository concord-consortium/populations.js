/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let SpeedSlider;
const PPSlider    = require('ui/ppslider');

module.exports = (SpeedSlider = class SpeedSlider {

  constructor(env) {
    this.view = document.createElement('div');
    this.view.setAttribute("style", "height: 20px;");

    const input = document.createElement('input');

    input.setAttribute("id", "speed-slider");
    input.setAttribute("type", 'hidden');
    input.setAttribute("value", 50);

    this.view.appendChild(input);

    // TODO Remove jQuery once we're no longer relying on it.
    $( document ).ready(function() {
      $(input).change(function() {
        return env.setSpeed(parseInt($(this).val()));
      });

      return $(input).PPSlider({width: env.width});
    });
  }

  getView() { return this.view; }
});


