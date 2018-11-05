/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let Toolbar;
const AddOrganismButton = require("ui/add-organism-button");
const RemoveOrganismButton = require("ui/remove-organism-button");
const ToolButton  = require('ui/tool-button');
const Events = require('events');
const Environment = require('models/environment');

module.exports = (Toolbar = class Toolbar {

  constructor(interactive) {
    let button;
    this.interactive = interactive;
    const env = this.interactive.environment;

    this.modalButtons = [];
    this.toggleButtons = [];
    this.organismButtons = [];

    this.view = document.createElement('div');
    this.view.classList.add("toolbar");
    this.view.setAttribute("style", `height: ${env.height}px;`);

    if (this.interactive.showPlayButton()) {
      this.addToggleButton("play", (() => env.start()),
        "pause", (() => env.stop()));
      // make sure we keep the button state in sync with the environment state
      Events.addEventListener(Environment.EVENTS.PLAY, () => {
        this.toggleButtons['play'].style.display="none";
        return this.toggleButtons['pause'].style.display="";
      });
      Events.addEventListener(Environment.EVENTS.STOP, () => {
        this.toggleButtons['play'].style.display="";
        return this.toggleButtons['pause'].style.display="none";
      });
    }
    for (var opts of Array.from(this.interactive.addOrganismButtons)) {
      button = new AddOrganismButton(env, this, opts);
      this.view.appendChild(button.render());
      this.organismButtons.push(button);

      if (opts.showRemoveButton) {
        const removeButton = new RemoveOrganismButton(env, this, opts);
        this.view.appendChild(removeButton.render());
        this.organismButtons.push(removeButton);
      }
    }

    for (opts of Array.from(this.interactive.toolButtons)) {
      button = new ToolButton(env, this, opts);
      this.view.appendChild(button.render());
    }

    if (this.interactive.showResetButton()) {
      this.addButton("reset", () => {
        this.reset();
        return env.reset();
      });
    }
  }

  addButton(type, action) {
    const button = document.createElement('div');
    button.classList.add('button');

    const innerButton = document.createElement('div');
    innerButton.classList.add(type);
    button.appendChild(innerButton);

    button.addEventListener('click', action);
    this.toggleButtons[type] = button;
    return this.view.appendChild(button);
  }

  addToggleButton(type1, action1, type2, action2) {
    const button1 = this.addButton(type1, action1);
    const button2 = this.addButton(type2, action2);
    button2.style.display="none";

    button1.addEventListener('click', function() {
      button1.style.display="none";
      return button2.style.display="";
    });

    return button2.addEventListener('click', function() {
      button1.style.display="";
      return button2.style.display="none";
    });
  }

  registerModalButton(btn) {
    return this.modalButtons.push(btn);
  }

  activateModalButton(btn) {
    btn.getView().classList.add('modal-active');
    return (() => {
      const result = [];
      for (let button of Array.from(this.modalButtons)) {
        if (button !== btn) {
          result.push(button.getView().classList.remove('modal-active'));
        } else {
          result.push(undefined);
        }
      }
      return result;
    })();
  }

  reset() {
    for (var button of Array.from(this.modalButtons)) {
      button.getView().classList.remove('modal-active');
    }
    for (button of Array.from(this.organismButtons)) {
      button.reset();
    }
    const env = this.interactive.environment;
    return env.setState(env.UI_STATE.NONE);
  }



  getView() {
    return this.view;
  }
});
