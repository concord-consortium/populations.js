/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS202: Simplify dynamic range loops
 * DS203: Remove `|| {}` from converted for-own loops
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
let AgentView;
require('animated-sprite');
const helpers       = require('helpers');
const AnimatedAgent = require('models/agents/animated-agent');

module.exports = (AgentView = (function() {
  AgentView = class AgentView {
    static initClass() {
  
      this.prototype._images = null;
      this.prototype._sprites = null;
      this.prototype._container = null;
  
      this.prototype.defaultTextViewOptions = {
        leaves: true,
        roots: true
      };
    }

    constructor({agent}) {
      this.agent = agent;
      this.imageProperties = (this.agent.species != null ? this.agent.species.imageProperties : undefined) || {};
    }

    render(stage, context) {
      if (context == null) { context = 'environment'; }
      const container = new PIXI.DisplayObjectContainer;
      const sprites = {};
      // create a texture from set of image paths
      const images = this.agent.getImages({context});
      for (let layer of Array.from(images)) {
        const sprite = this._createOrUpdateSprite(layer.selectedImage);
        sprites[layer.name] = sprite;
        container.addChild(sprite);
      }

      container.position.x = this.agent._x;
      container.position.y = this.agent._y;
      container.agent = this.agent;

      stage.addChild(container);

      if ((context === 'environment') || (context === 'carry-tool')) {
        this._rendered = true;
        this._container = container;
        this._sprites = sprites;
        return this._images = images;
      }
    }

    rerender(stage, context) {
      let i, layer, sprite;
      if (context == null) { context = 'environment'; }
      if (!this._rendered) {
        this.render(stage, context);
        return;
      }
      const newImages = this.agent.getImages({context});
      const names = [];
      // update or create needed sprites
      for (i = 0; i < newImages.length; i++) {
        layer = newImages[i];
        names.push(layer.name);
        if ((this._sprites[layer.name] == null)) {
          sprite = this._createOrUpdateSprite(layer.selectedImage);
          this._sprites[layer.name] = sprite;
          this._container.addChildAt(sprite,i);
        } else if ((layer.selectedImage.path != null) && (layer.selectedImage.path !== this._sprites[layer.name].texture.baseTexture.source.src)) {
          this._createOrUpdateSprite(layer.selectedImage, this._sprites[layer.name]);
        } else if (this._sprites[layer.name] instanceof PIXI.AnimatedSprite) {
          var animation;
          const currentMovement = this.agent.getMovement();
          // i = _i for animation, _i in layer.selectedImage.animations when animation.movement is currentMovement
          for (let _animation of Array.from(layer.selectedImage.animations)) { if (_animation.movement === currentMovement) { animation = _animation; } }
          if (animation && (animation.path !== this._sprites[layer.name].sequences[animation.movement].path)) {
            // this._sprites[layer.name].sequences[layer.selectedImage.animations[0].movement]
            sprite = this._sprites[layer.name];
            this._createOrUpdateSprite(layer.selectedImage, sprite);
          } else { this._setSpriteProperties(this._sprites[layer.name], layer.selectedImage); }
        } else {
          this._setSpriteProperties(this._sprites[layer.name], layer.selectedImage);
        }
      }

      // remove the no-longer-needed sprites
      for (let name of Object.keys(this._sprites || {})) {
        sprite = this._sprites[name];
        if (names.indexOf(name) === -1) {
          this._container.removeChild(sprite);
          delete this._sprites[name];
        }
      }

      this._container.position.x = this.agent._x;
      this._container.position.y = this.agent._y;

      for (i = 0; i < newImages.length; i++) {
        layer = newImages[i];
        if (((sprite = this._sprites[layer.name]) != null) && sprite instanceof PIXI.AnimatedSprite) {
          const sequence = (this.agent.environment._isRunning) ? this.agent.getMovement() : AnimatedAgent.MOVEMENTS.STOPPED;
          if (!sequence || (sprite.sequences[sequence] == null)) { return; }
          if (sequence !== sprite.currentSequence) {
            if (!sprite.playing) {
              sprite.gotoAndPlay(sequence);
            } else {
              if ((sprite.sequences[sprite.currentSequence] != null ? sprite.sequences[sprite.currentSequence].interruptible : undefined)) {
                sprite.gotoAndPlay(sequence);
              } else {
                sprite.nextSequence = sequence;
              }
            }
          }
          sprite.advanceTime();
        }
      }
    }

    remove(stage){
      try {
        if (this._rendered) { if (stage != null) {
          stage.removeChild(this._container);
        } }
      } catch (e) {
        console.error("Tried to remove an agent from a stage it wasn't rendered within.");
      }
      return this._rendered = false;
    }

    contains(x,y){
      if (!this._container) { return false; }
      const intManager = new PIXI.InteractionManager();
      return intManager.hitTest(this._container, {
        global: {
          x,
          y
        }
      }
      );
    }

    textView(options){
      if (options == null) { options = {}; }
      const opts = helpers.setDefaults(options, this.defaultTextViewOptions);
      const content = document.createElement('div');

      if (this.agent.species.defs.INFO_VIEW_PROPERTIES != null) {
        for (let k of Object.keys(this.agent.species.defs.INFO_VIEW_PROPERTIES || {})) {
          const v = this.agent.species.defs.INFO_VIEW_PROPERTIES[k];
          this._appendPropVals(content, k, v);
        }
      }

      return content;
    }

    _appendPropVals(container, propLabel, propKey){
      const prop = document.createElement('div');
      prop.classList.add('agent-property');
      prop.innerHTML = propLabel;

      const val = document.createElement('div');
      val.classList.add('agent-property-value');
      val.innerHTML = this.agent.get(propKey);

      container.appendChild(prop);
      container.appendChild(val);
      return container;
    }

    _createOrUpdateSprite(image, sprite){
      // create a new Sprite using the texture
      if (!image.animations) {
        let texture;
        if (image.path) {
          texture = PIXI.Texture.fromImage(image.path);
        } else if (image.render) {
          const graphics = new PIXI.Graphics();
          image.render(graphics);
          texture = graphics.generateTexture();
        }

        if (!sprite) {
          sprite = new PIXI.Sprite(texture);
        } else {
          sprite.setTexture(texture);
        }
        this._setSpriteProperties(sprite, image);
      } else {

        var setupAnimatedSprite = (image, sprite)=> {
          let sequences;
          for (let animation of Array.from(image.animations)) {
            const spriteTextures = [];
            for (let i = 0, end = animation.length, asc = 0 <= end; asc ? i < end : i > end; asc ? i++ : i--) {
              spriteTextures.push(PIXI.Texture.fromFrame(animation.animationName+"-"+i));
            }

            if (!sprite) {
              sequences = {};
              sequences[animation.movement]               = {frames: spriteTextures};
              if (animation.frameRate) { sequences[animation.movement].frameRate     = animation.frameRate; }
              if (animation.loop) { sequences[animation.movement].loop          = animation.loop; }
              if (animation.onComplete) { sequences[animation.movement].onComplete    = animation.onComplete; }
              sequences[animation.movement].interruptible = animation.interruptible;
              sequences[animation.movement].path          = animation.path;
              sprite = new PIXI.AnimatedSprite(sequences);
            } else {
              sprite.sequences[animation.movement]                = {frames: spriteTextures};
              if (animation.frameRate) { sprite.sequences[animation.movement].frameRate      = animation.frameRate; }
              if (animation.loop) { sprite.sequences[animation.movement].loop           = animation.loop; }
              if (animation.onComplete) { sprite.sequences[animation.movement].onComplete     = animation.onComplete; }
              sprite.sequences[animation.movement].interruptible  = animation.interruptible;
              sprite.sequences[animation.movement].path           = animation.path;
            }
          }

          sprite.nextSequence = null;
          sprite.onComplete = sequence => {
            let func;
            if (func = sprite.sequences[sprite.currentSequence].onComplete) {
              this.agent[func]();
            }
            if (sprite.nextSequence) {
              sprite.gotoAndPlay(sprite.nextSequence);
              sprite.nextSequence = null;
            } else {
              if (!sprite.sequences[sequence].loop) {
                sprite.currentSequence = null;
              }
            }
            if (sprite.nextImage != null) {
              setupAnimatedSprite(image, sprite);
              return sprite.nextImage = null;
            }
          };

          this._setSpriteProperties(sprite, image);
          return sprite;
        };


        if (sprite && sprite.playing) {
          sprite.nextImage = image;
        } else {
          sprite = setupAnimatedSprite(image, sprite);
        }
      }

      return sprite;
    }

    _setSpriteProperties(sprite, image){
      // default scale of 1 -- same size as the original image
      let d;
      let scale = image.scale || 1;
      scale *= this.agent.getSize();
      sprite.scale.x = scale;
      sprite.scale.y = scale;

      if (this.imageProperties.initialFlipDirection) {
        d = ExtMath.normalizeRads(this.agent.get('direction'));
        switch (this.imageProperties.initialFlipDirection) {
          case "left":
            if (-ExtMath.HALF_PI < d && d < ExtMath.HALF_PI) { sprite.scale.x *= -1; }
            break;
          case "right":
            if ((-ExtMath.HALF_PI > d) || (d > ExtMath.HALF_PI)) { sprite.scale.x *= -1; }
            break;
          case "up":
            if (0 < d && d < Math.PI) { sprite.scale.y *= -1; }
            break;
          case "down":
            if (-Math.PI < d && d < 0) { sprite.scale.y *= -1; }
            break;
        }
      }

      if (this.imageProperties.rotate) {
        const initialDirection = this.imageProperties.initialRotationDirection || 0;
        d = ExtMath.normalizeRads(this.agent.get('direction'));
        const dd = d - initialDirection;
        sprite.rotation = dd;
      }


      // default anchor of 0.5 -- the image is centered on the container's position
      sprite.anchor.x = ((image.anchor != null ? image.anchor.x : undefined) != null) ? image.anchor.x : 0.5;
      sprite.anchor.y = ((image.anchor != null ? image.anchor.y : undefined) != null) ? image.anchor.y : 0.5;

      // default position of 0 -- the image won't be shifted up/down or left/right
      sprite.position.x = ((image.position != null ? image.position.x : undefined) != null) ? image.position.x : 0;
      sprite.position.y = ((image.position != null ? image.position.y : undefined) != null) ? image.position.y : 0;
      return sprite;
    }
  };
  AgentView.initClass();
  return AgentView;
})());
