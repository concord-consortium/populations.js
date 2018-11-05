// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

// const PPSlider    = require('ui/ppslider');

// TODO: No more jQuery, fix this

export default class SpeedSlider {

  constructor(env) {
    this.view = document.createElement('div');
    this.view.setAttribute("style", "height: 20px;");

    const input = document.createElement('input');

    input.setAttribute("id", "speed-slider");
    // input.setAttribute("type", 'hidden');
    input.setAttribute("value", 50);

    this.view.appendChild(input);

    // TODO Remove jQuery once we're no longer relying on it.
    // $( document ).ready(function() {
    //   $(input).change(function() {
    //     return env.setSpeed(parseInt($(this).val()));
    //   });

    //   return $(input).PPSlider({width: env.width});
    // });
  }

  getView() { return this.view; }
};


