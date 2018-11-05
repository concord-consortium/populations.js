// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS202: Simplify dynamic range loops
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
export default class AddOrganismButton {

  constructor(environment, toolbar, {species, traits, scatter, limit, imagePath, showRemoveButton}) {
    this.environment = environment;
    this.toolbar = toolbar;
    this.species = species;
    this.traits = traits;
    this.scatter = scatter;
    this.limit = limit;
    this.imagePath = imagePath;
    this.showRemoveButton = showRemoveButton;
    this._count = 0;
    this._disabled = false;
    if (!this.scatter) {
      this.toolbar.registerModalButton(this);
    }
  }


  render() {
    this.button = document.createElement('div');
    this.button.classList.add('button');
    if (this.showRemoveButton) { this.button.classList.add('has-no-button'); }
    this.button.addEventListener('click', () => this.action());
    if (!this.scatter) { this.button.classList.add('modal'); }

    const image = document.createElement('img');
    image.setAttribute('src', this.imagePath);
    this.button.appendChild(image);

    return this.button;
  }

  getView() { return this.button; }

  disable() {
    this._disabled = true;
    return this.button.classList.add('disabled');
  }

  reset() {
    this._count = 0;
    this._disabled = false;
    return this.button.classList.remove('disabled');
  }

  action() {
    if (this._disabled) { return; }
    if (this.scatter) {
      return this.scatterOrganisms();
    } else {
      return this.enterAddOrganismsMode();
    }
  }

  scatterOrganisms() {
    for (let i = 0, end = this.scatter, asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) {
      if (this.limit && (++this._count >= this.limit)) {
        this.disable();
        if (this._count > this.limit) { return; }
      }

      const agent = this.species.createAgent(this.traits);
      agent.environment = this.environment;
      agent.setLocation(this.environment.randomLocation());

      while (!this.environment.addAgent(agent)) {
        agent.setLocation(this.environment.randomLocation());
      }
    }
  }

  enterAddOrganismsMode() {
    this.toolbar.activateModalButton(this);
    this.environment.setDefaultAgentCreator(this.species, this.traits, () => {
      if (this.limit && (++this._count >= this.limit)) {
        this.environment.setDefaultAgentCreator(null);
        this.environment.setState(this.environment.UI_STATE.NONE);
        return this.disable();
      }
    });

    return this.environment.setState(this.environment.UI_STATE.ADD_AGENTS);
  }
}