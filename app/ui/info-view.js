// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import PIXI from '../../bower_components/pixi.js/bin/pixi';

const _instances = [];

export default class InfoView {

  static instances() {
    return _instances;
  }

  constructor({agent}){
    this.agent = agent;
    this.view = null;
    _instances.push(this);
  }
  setAgent(agent){
    this.agent = agent;
    while (this._container.children.length > 0) {
      this._container.removeChild(this._container.children[0]);
    }
    this.agent.getView().render(this._container, 'info-tool');
    this._repositionAgent();
    this._rescaleAgent();

    if (this._details.firstChild != null) {
      this._details.replaceChild(this.agent.getView().textView(), this._details.firstChild);
    } else {
      this._details.appendChild(this.agent.getView().textView());
    }

    return this.title.innerHTML = this.agent.label.charAt(0).toUpperCase() + this.agent.label.slice(1);
  }

  _repositionAgent() {
    this._container.children[0].position = { x: 0, y: 0 };
    return this._container.position = { x: 52, y: 70 };
  }

  _rescaleAgent() {
    if (this.agent.species.defs.INFO_VIEW_SCALE != null) {
      this._container.scale.x = this.agent.species.defs.INFO_VIEW_SCALE;
      return this._container.scale.y = this.agent.species.defs.INFO_VIEW_SCALE;
    } else {
      this._container.scale.x = 1.25;
      return this._container.scale.y = 1.25;
    }
  }

  _redraw() {
    if (this._showing) { window.requestAnimationFrame(() => this._redraw()); }
    return this._renderer.render(this._stage);
  }

  render() {
    this.view = document.createElement('div');
    this.view.classList.add('bubble');

    if (this.agent._x < (this.agent.environment.width/2)) { this.view.classList.add('left'); } else { this.view.classList.add('right'); }
    if (this.agent._y < (this.agent.environment.height/2)) { this.view.classList.add('top'); } else { this.view.classList.add('bottom'); }

    const titleBar = document.createElement('div');
    titleBar.classList.add('title-bar');

    this.title = document.createElement('span');
    this.title.classList.add('title');
    this.title.innerHTML = this.agent.label.charAt(0).toUpperCase() + this.agent.label.slice(1);

    const closeButton = document.createElement('span');
    closeButton.classList.add('close');
    closeButton.innerHTML = "<i class='fa fa-times-circle-o'></i>";
    closeButton.addEventListener('click', () => {
      return this.hide();
    });

    const content = document.createElement('div');
    content.classList.add('content');

    this._details = document.createElement('div');
    this._details.classList.add('details');

    const agentView = document.createElement('div');
    agentView.classList.add('agent');
    this._stage = new PIXI.Stage(0xFFFFFF, true);
    this._renderer = new PIXI.CanvasRenderer(125, 160, {transparent: true});
    this._container = new PIXI.DisplayObjectContainer();
    this._stage.addChild(this._container);
    this.setAgent(this.agent);
    this._redraw();
    agentView.appendChild(this._renderer.view);

    titleBar.appendChild(this.title);
    titleBar.appendChild(closeButton);

    content.appendChild(agentView);
    content.appendChild(this._details);

    this.view.appendChild(titleBar);
    this.view.appendChild(content);

    return this.view;
  }

  hide() {
    if (!this.view.classList.contains('hidden')) { this.view.classList.add('hidden'); }
    return this._showing = false;
  }

  show() {
    this.view.classList.remove('hidden');
    this._showing = true;
    return this._redraw();
  }

  repaint() {
    return this._renderer.render(this._stage);
  }
}
