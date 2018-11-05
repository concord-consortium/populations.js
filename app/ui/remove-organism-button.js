/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let RemoveOrganismButton;
const Events = require('events');
const Environment = require('models/environment');

module.exports = (RemoveOrganismButton = (function() {
  RemoveOrganismButton = class RemoveOrganismButton {
    static initClass() {
  
      this.prototype._disabled = false;
    }

    constructor(environment, toolbar, {species, imagePath}) {
      this.environment = environment;
      this.toolbar = toolbar;
      this.species = species;
      this.imagePath = imagePath;
      undefined;
    }

    render() {
      this.button = document.createElement('div');
      this.button.classList.add('button');
      this.button.classList.add('no-button');
      this.button.addEventListener('click', () => this.action());

      const image = document.createElement('img');
      image.setAttribute('src', this.imagePath);
      this.button.appendChild(image);

      const noImage = document.createElement('div');
      noImage.classList.add('no-sign');
      this.button.appendChild(noImage);

      return this.button;
    }

    getView() { return this.button; }

    disable() {
      this._disabled = true;
      return this.button.classList.add('disabled');
    }

    reset() {
      this._disabled = false;
      return this.button.classList.remove('disabled');
    }

    action() {
      if (this._disabled) { return; }
      this.removeOrganisms();
      return Events.dispatchEvent(Environment.EVENTS.USER_REMOVED_AGENTS, {species: this.species});
    }

    removeOrganisms() {
      for (let agent of Array.from(this.environment.agents)) {
        if (agent.species === this.species) {
          agent.die();
        }
      }
      return this.environment.removeDeadAgents();
    }
  };
  RemoveOrganismButton.initClass();
  return RemoveOrganismButton;
})());
