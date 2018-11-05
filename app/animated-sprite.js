/*
 * decaffeinate suggestions:
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
PIXI.AnimatedSprite = function(sequences, firstSequence) {
  this.sequences  = sequences;
  if (firstSequence == null) {
    for (let key in sequences) {
      this.currentSequence = key;
      break;
    }
  } else {
    this.currentSequence = firstSequence;
  }

  this.frames = this.sequences[this.currentSequence].frames;
  this.frameRate = this.sequences[this.currentSequence].frameRate || 60;
  this.loop = this.sequences[this.currentSequence].loop || false;

  PIXI.Sprite.call(this, this.frames[0]);
  this.anchor.x = (this.anchor.y = .5);
  this.onComplete = null;
  this.currentFrame = 0;
  this.previousFrame;
  this.playing = false;
  this.loop = false;
};


//animatedSprite
PIXI.AnimatedSprite.constructor = PIXI.AnimatedSprite;
PIXI.AnimatedSprite.prototype = Object.create(PIXI.Sprite.prototype);
PIXI.AnimatedSprite.prototype.gotoAndPlay = function(where) {
  if (Object.prototype.toString.call(where) === "[object String]") {
    this.currentFrame = 0;
    this.currentSequence = where;
    this.frames = this.sequences[where].frames;
    this.frameRate = this.sequences[where].frameRate || 60;
    this.loop = this.sequences[where].loop || false;
  } else {
    this.frames = this.sequences[this.currentSequence].frames;
    this.currentFrame = where;
  }
  this.playing = true;
};

PIXI.AnimatedSprite.prototype.gotoAndStop = function(where) {
  if (Object.prototype.toString.call(where) === "[object String]") {
    this.currentFrame = 0;
    this.currentSequence = where;
    this.frames = this.sequences[where].frames;
    this.frameRate = this.sequences[where].frameRate || 60;
    this.loop = this.sequences[where].loop || false;
  } else {
    this.currentFrame = where;
  }
  this.setTexture(this.frames[this.currentFrame]);
  this.playing = false;
};

PIXI.AnimatedSprite.prototype.play = function() {
  this.playing = true;
};

PIXI.AnimatedSprite.prototype.stop = function() {
  this.playing = false;
};

PIXI.AnimatedSprite.prototype.advanceTime = function(dt) {
  if (typeof dt === "undefined") { dt = 1 / 60; }
  if (this.playing) {
    this.currentFrame += this.frameRate * dt;
    const constrainedFrame = Math.floor(Math.min(this.currentFrame, this.frames.length - 1));
    this.setTexture(this.frames[constrainedFrame]);
    if (this.currentFrame >= this.frames.length) {
      if (this.loop) {
        this.gotoAndPlay(0);
      } else {
        this.stop();
      }
      if (this.onComplete) { this.onComplete(this.currentSequence); }
    }
  }
};
