import PIXI from '../../bower_components/pixi.js/bin/pixi';

const cursorsClasses = [
  "add-agents",
  "info-tool",
  "carry-tool"
];

export default class EnvironmentView {
  constructor({environment}) {
    this.showingBarriers = false;
    this._backgroundSprite = null;
    this.environment = environment;
    this.showingWinter = false;
    this._layers = [];
    this.baseScale = this.environment.viewWidth / this.environment.width;
    if (this.environment.winterImgPath) {
      this.winterImgSprite = new PIXI.TilingSprite(PIXI.Texture.fromImage(this.environment.winterImgPath),
        this.environment.viewWidth, this.environment.viewHeight);
      this.winterImgSprite.anchor.x = 0;
      this.winterImgSprite.anchor.y = 0;
      this.winterImgSprite.position.x = 0;
      this.winterImgSprite.position.y = 0;
    }
  }

  render(el) {
    if (this.stage == null) { this.stage = new PIXI.Stage(0xFFFFFF, true); }
    this.renderer = new PIXI.autoDetectRenderer(this.environment.viewWidth, this.environment.viewHeight);
    // create a texture from an image path
    const texture = PIXI.Texture.fromImage(this.environment.imgPath);

    const layer = this._getOrCreateLayer(0);
    // create a new Sprite using the texture
    this._backgroundSprite = new PIXI.Sprite(texture);

    this._backgroundSprite.anchor.x = 0;
    this._backgroundSprite.anchor.y = 0;

    this._backgroundSprite.position.x = 0;
    this._backgroundSprite.position.y = 0;

    this.scaleBackground();

    layer.addChild(this._backgroundSprite);

    this.renderBarriers(layer);

    this.renderAgents();

    this._sortStage();

    var animate = () => {
      window.requestAnimationFrame( animate );
      for (let agent of this.environment.agents) {

        agent.getView().rerender(this._getOrCreateLayer(agent._viewLayer), 'environment', this.baseScale);
      }

      if (this.environment.carriedAgent) {
        this.environment.carriedAgent.getView().rerender(this._getOrCreateLayer(100), 'carry-tool');
      }

      this.barrierGraphics.visible = this.showingBarriers;
      this._sortStage();
      this.renderer.render(this.stage);
    };

    window.requestAnimationFrame( animate );

    this.view = this.renderer.view;

    this.addMouseHandlers();

    return this.view;
  }

  repaint() {
    this.renderer.render(this.stage);
  }

  renderAgents(stage) {
    this.environment.agents.map((agent) =>
      agent.getView().render(this._getOrCreateLayer(agent._viewLayer), 'environment', this.baseScale));
  }

  renderBarriers(stage) {
    this.barrierGraphics = new PIXI.Graphics();

    this.rerenderBarriers();

    stage.addChild(this.barrierGraphics);
  }

  rerenderBarriers() {
    while (this.barrierGraphics.children.length > 0) {
      this.barrierGraphics.removeChild(this.barrierGraphics.children[0]);
    }
    this.barrierGraphics.clear();

    // set a fill and line style
    this.barrierGraphics.beginFill(0xFF3300, 0.5);
    this.barrierGraphics.lineStyle(1, 0xffd900, 0.5);

    // draw each barrier
    for (let i = 0; i < this.environment.barriers.length; i++) {
      const b = this.environment.barriers[i];
      this.barrierGraphics.drawRect(b.x1, b.y1, b.x2-b.x1, b.y2-b.y1);
      const text = new PIXI.Text(`${i}`);
      text.position = {x: b.x1+5, y: b.y1+5};
      this.barrierGraphics.addChild(text);
    }

    this.barrierGraphics.endFill();
    this.barrierGraphics.visible = this.showingBarriers;
  }

  removeAgent(agent){
    agent.getView().remove(this._getOrCreateLayer(agent._viewLayer));
  }

  removeCarriedAgent(agent){
    agent.getView().remove(this._getOrCreateLayer(100));
  }

  setCursor(name) {
    if (!this.view) { return; }
    for (let cursorClass of cursorsClasses) {
      this.view.parentElement.classList.remove(cursorClass);
    }

    this.view.parentElement.classList.add(name);
  }

  addWinterImage() {
    this.showingWinter = true;
    const layer = this._getOrCreateLayer(101);
    if (!!this.winterImgSprite) { layer.addChild(this.winterImgSprite); }
  }

  removeWinterImage() {
    this.showingWinter = false;
    const layer = this._getOrCreateLayer(101);
    if (!!this.winterImgSprite) { layer.removeChild(this.winterImgSprite); }
  }

  addMouseHandlers() {
    ["click", "mousedown", "mouseup", "mousemove", "touchstart", "touchmove", "touchend"].map((eventName) =>
      this.view.addEventListener(eventName,  evt => {
        const rect = this.view.getBoundingClientRect();
        const scale = rect.width / this.environment.width;
        if (evt instanceof TouchEvent) {
          // touch events get their coordinates from a different place
          evt.envX = (evt.changedTouches[0].pageX - rect.x) / scale;
          evt.envY = (evt.changedTouches[0].pageY - rect.y) / scale;
        } else {
          evt.envX = (evt.pageX - rect.x) / scale;
          evt.envY = (evt.pageY - rect.y) / scale;
        }

        this.environment.send(evt.type, evt);
        this.environment.notifyListeners(evt);
      }));
  }

  updateBackground() {
    const texture = PIXI.Texture.fromImage(this.environment.imgPath);
    this._backgroundSprite.setTexture(texture);
    this.scaleBackground();
  }

  // scales background relative to actual env size
  scaleBackground() {
    const scaleX = this.environment.viewWidth / this._backgroundSprite.width;
    const scaleY = this.environment.viewHeight / this._backgroundSprite.height;
    const scale = Math.max(scaleX, scaleY);
    this._backgroundSprite.width *= scale;
    this._backgroundSprite.height *= scale;
  }

  get canvas() {
    return this.renderer.view;
  }

  get container() {
    return this.canvas.parentElement;
  }

  _getOrCreateLayer(idx){
    if ((this._layers[idx] == null)) {
      const layer = new PIXI.DisplayObjectContainer;
      this._layers[idx] = layer;
      if (this.stage) {
        try {
          let layerNo = 0;
          for (let key of Object.keys(this._layers)) {
            if (idx > key) { layerNo++; } else { break; }
          }
          this.stage.addChildAt(layer, layerNo);
        } catch (error) {
          // FIXME We should find out if the layers at the end of the array are supposed to be above or below our new layer
          this.stage.addChild(layer);
        }
      }
    }
    return this._layers[idx];
  }

  _sortStage() {
    if (!this.environment.depthPerception) { return; }
    // sort each of the stage's childrens' children by y value, ascending, so that agents on the bottom of the environment
    // will be drawn on top of agents higher up in the environment
    this.stage.children.map((container) =>
      container.children.sort(function(a,b){
        const aIdx = (a.agent && a.agent.zIndex)
          ? a.agent.zIndex()
          : ((a.position.y * this.environment.viewWidth) + a.position.x);
        const bIdx = (b.agent && b.agent.zIndex)
          ? b.agent.zIndex()
          : ((b.position.y * this.environment.viewWidth) + b.position.x);
        return aIdx - bIdx;
      }));
  }
}
