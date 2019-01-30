import * as helpers from '../helpers';
import Toolbar from './toolbar';
import InfoView from './info-view';
import SpeedSlider from './speed-slider';
import Events from '../events';
import Environment from '../models/environment';

const defaultOptions = {
  environment : null,
  playButton  : true,
  resetButton : true,
  speedSlider : false,
  addOrganismButtons  : [],
  toolButtons: [],
  showToolbar: true
};

export default class Interactive {

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
        this.repaint();
      });
    }
    if (typeof iframePhone !== 'undefined' && iframePhone !== null) {
      const phone = iframePhone.getIFrameEndpoint();
      let ignoreEvent = false;
      phone.addListener('stop', () => {
        ignoreEvent = true;
        this.stop();
        ignoreEvent = false;
      });
      phone.addListener('play', () => {
        ignoreEvent = true;
        this.play();
        ignoreEvent = false;
      });
      phone.addListener('reset', () => {
        ignoreEvent = true;
        this.reset();
        ignoreEvent = false;
      });
      Events.addEventListener(Environment.EVENTS.START, function() {
        if (!ignoreEvent) { phone.post({type: 'play'}); }
      });
      Events.addEventListener(Environment.EVENTS.STOP, function() {
        if (!ignoreEvent) { phone.post({type: 'stop'}); }
      });
      Events.addEventListener(Environment.EVENTS.RESET, function() {
        if (!ignoreEvent) { phone.post({type: 'reset'}); }
      });
      phone.initialize();
    }
  }

  getEnvironmentPane() {
    this.container = document.createElement('div');
    this.container.setAttribute("class", "populations-interactive");

    if (this._opts.speedSlider) {
      const top = document.createElement('div');
      top.setAttribute("class", "interactive-top");

      const speedSlider = new SpeedSlider(this.environment);
      top.appendChild(speedSlider.getView());
      this.container.appendChild(top);
    }

    this.main = document.createElement('div');
    this.main.setAttribute("class", "interactive-main");

    this.main.appendChild(this.environment.getView().render());

    this.toolbar = new Toolbar(this);
    if (this._opts.showToolbar) {
      this.main.appendChild(this.toolbar.getView());
    }

    this.container.appendChild(this.main);

    return this.container;
  }

  showPlayButton() { return this._opts.playButton; }
  showResetButton() { return this._opts.resetButton; }

  get isPlaying() {
    return this.environment._isRunning;
  }

  setEnvironmentDisplayWidth(width) {
    this.scale(width / this.environment.viewWidth);
  }

  setEnvironmentDisplayHeight(height) {
    this.scale(height / this.environment.viewHeight);
  }

  constrain(width, height) {
    const xScale = width / this.environment.viewWidth;
    const yScale = height / this.environment.viewHeight;
    this.scale(Math.min(xScale, yScale));
  }

  scale(scale) {
    this.main.style.transformOrigin = "0 0";
    this.main.style.transform = `scale(${scale})`;

    const newRect = this.main.getBoundingClientRect();
    this.container.style.width = Math.ceil(newRect.width) + "px";
    this.container.style.height = Math.ceil(newRect.height) + "px";
  }

  repaint() {
    for (let view of InfoView.instances()) {
      view.repaint();
    }
    this.environment.getView().repaint();
  }

  play() {
    if (!this.isPlaying) { this.toolbar.toggleButtons['play'].click(); }
  }

  stop() {
    if (this.isPlaying) { this.toolbar.toggleButtons['pause'].click(); }
  }

  togglePlay() {
    if (!this.isPlaying) {
      this.play();
    } else {
      this.stop();
    }
  }

  reset() {
    this.toolbar.toggleButtons['reset'].click();
  }

  addMouseListener(listener) {
    this.environment.addMouseListener(listener);
  }

  addAgentMouseListener(listener, distance) {
    this.environment.addMouseListener(listener, true, distance);
  }
};

window.onerror = function(msg, url, line){
  let message = `<div>There was an error in the model!<br/><pre>${msg}</pre></div>`;
  message += `<div>source: ${url}, line: ${line}</div>`;
  helpers.showMessage(message, document.body);
};
