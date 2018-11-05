// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Interactive;
const helpers = require("helpers");
const Toolbar = require("ui/toolbar");
const InfoView = require("ui/info-view");
const SpeedSlider = require("ui/speed-slider");
const Events = require('events');
const Environment = require('models/environment');

const defaultOptions = {
  environment : null,
  playButton  : true,
  resetButton : true,
  speedSlider : false,
  addOrganismButtons  : [],
  toolButtons: []
};

module.exports = (Interactive = class Interactive {

  constructor(options) {
    this._opts = helpers.setDefaults(options, defaultOptions);
    this.environment = this._opts.environment;
    this.addOrganismButtons = this._opts.addOrganismButtons;
    this.toolButtons = this._opts.toolButtons;
    if (typeof Shutterbug !== 'undefined' && Shutterbug !== null) {
      window.shutterbug = new Shutterbug("body");

      // When Shutterbug wants to take a snapshot of the page, it first emits a 'shutterbug-
      // saycheese' event. By default, any WebGL canvas will return a blank image when Shutterbug
      // calls .toDataURL on it, However, if we ask Pixi to render to the canvas during the
      // Shutterbug event loop (remember synthetic events such as 'shutterbug-saycheese' are
      // handled synchronously) the rendered image will still be in the WebGL drawing buffer where
      // Shutterbug can see it.
      $(window).on('shutterbug-saycheese', () => {
        return this.repaint();
      });
    }
    if (typeof iframePhone !== 'undefined' && iframePhone !== null) {
      const phone = iframePhone.getIFrameEndpoint();
      let ignoreEvent = false;
      phone.addListener('stop', () => {
        ignoreEvent = true;
        this.stop();
        return ignoreEvent = false;
      });
      phone.addListener('play', () => {
        ignoreEvent = true;
        this.play();
        return ignoreEvent = false;
      });
      phone.addListener('reset', () => {
        ignoreEvent = true;
        this.reset();
        return ignoreEvent = false;
      });
      Events.addEventListener(Environment.EVENTS.START, function() {
        if (!ignoreEvent) { return phone.post({type: 'play'}); }
      });
      Events.addEventListener(Environment.EVENTS.STOP, function() {
        if (!ignoreEvent) { return phone.post({type: 'stop'}); }
      });
      Events.addEventListener(Environment.EVENTS.RESET, function() {
        if (!ignoreEvent) { return phone.post({type: 'reset'}); }
      });
      phone.initialize();
    }
  }

  getEnvironmentPane() {
    this.view = document.createElement('div');

    this.view.setAttribute("style", `height: ${this.environment.height}px;`);

    if (this._opts.speedSlider) {
      const speedSlider = new SpeedSlider(this.environment);
      this.view.appendChild(speedSlider.getView());
    }

    this.view.appendChild(this.environment.getView().render());

    this.toolbar = new Toolbar(this);
    this.view.appendChild(this.toolbar.getView());

    return this.view;
  }

  showPlayButton() { return this._opts.playButton; }
  showResetButton() { return this._opts.resetButton; }

  repaint() {
    for (let view of Array.from(InfoView.instances())) {
      view.repaint();
    }
    return this.environment.getView().repaint();
  }

  play() {
    if (!this.environment._isRunning) { return this.toolbar.toggleButtons['play'].click(); }
  }

  stop() {
    if (this.environment._isRunning) { return this.toolbar.toggleButtons['pause'].click(); }
  }

  reset() {
    return this.toolbar.toggleButtons['reset'].click();
  }
});

window.onerror = function(msg, url, line){
  let message = `<div>There was an error in the model!<br/><pre>${msg}</pre></div>`;
  message += `<div>source: ${url}, line: ${line}</div>`;
  return helpers.showMessage(message, document.body);
};
