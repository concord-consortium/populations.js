// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import InfoView from './info-view';

export default class ToolButton {

  constructor(environment, toolbar, {type}) {

    this.state = null;

    this._states = {
      'info-tool': {
        enter() {
          return this._view.setCursor("info-tool");
        },
        click(evt) {
          // get clicked agent
          const agents = this.getAgentsAt(evt.envX, evt.envY).filter(a=> a.canShowInfo());
          if (!(agents.length > 0)) { return; }
          const agent = agents[0];
          // Display info pop-up for that agent
          if (this.infoPopup != null) {
            this.infoPopup.setAgent(agent);
          } else {
            this.infoPopup = new InfoView({agent});
            const envView = environment.getView();
            envView.container.appendChild(this.infoPopup.render());
          }
          for (let style of ['top','left','bottom','right']) {
            this.infoPopup.view.classList.remove(style);
          }
          if (evt.envX > (this.width/2)) {
            this.infoPopup.view.classList.add('right');
            this.infoPopup.view.style.left = (evt.envX - 225) + "px";
          } else {
            this.infoPopup.view.classList.add('left');
            this.infoPopup.view.style.left = (evt.envX + 35) + "px";
          }
          if (evt.envY > (this.height/2)) {
            this.infoPopup.view.classList.add('bottom');
            this.infoPopup.view.style.top = (evt.envY - 162) + "px";
          } else {
            this.infoPopup.view.classList.add('top');
            this.infoPopup.view.style.top = (evt.envY - 25) + "px";
          }
          return this.infoPopup.show();
        }
      },

      'carry-tool': {
        _agent: null,
        _origin: null,
        _agentOrigin: null,
        enter() {
          return this._view.setCursor("carry-tool");
        },
        mousedown(evt) {
          const agent = this.getAgentAt(evt.envX, evt.envY);
          if (agent == null) { return; }
          this.pickUpAgent(agent);
          this._agent = agent;
          this._origin = {x: evt.envX, y: evt.envY};
          return this._agentOrigin = agent.getLocation();
        },
        mousemove(evt) {
          if (this._agent == null) { return; }
          const dX = evt.envX - this._origin.x;
          const dY = evt.envY - this._origin.y;
          return this._agent.setLocation({x: this._agentOrigin.x + dX, y: this._agentOrigin.y + dY});
        },
        mouseup(evt) {
          if (this._agent == null) { return; }
          this.dropCarriedAgent();
          return this._agent = null;
        },
        touchstart(evt) {
          evt.preventDefault();
          return this.send('mousedown', evt);
        },
        touchmove(evt) {
          evt.preventDefault();
          return this.send('mousemove', evt);
        },
        touchend(evt) {
          evt.preventDefault();
          return this.send('mouseup', evt);
        }
      }
    };


    this.environment = environment;
    this.toolbar = toolbar;
    this.type = type;
    this.toolbar.registerModalButton(this);
    this.state = this._getState();
    this.environment.addState(this.type, this.state);

  }

  render() {
    this.button = document.createElement('div');
    this.button.classList.add('button');
    this.button.addEventListener('click', () => this.action());
    this.button.classList.add('modal');

    const image = document.createElement('div');
    image.classList.add(this.type);
    this.button.appendChild(image);

    return this.button;
  }

  getView() { return this.button; }

  action() {
    this.toolbar.activateModalButton(this);
    return this.environment.setState(this.type);
  }

  _getState() {
    return this._states[this.type];
  }
}

ToolButton.INFO_TOOL = 'info-tool';
ToolButton.CARRY_TOOL = 'carry-tool';