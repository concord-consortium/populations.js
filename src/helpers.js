import PIXI from '../bower_components/pixi.js/bin/pixi';

// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// [a,b,c,d].remove(1) => [a,c,d]
// [a,b,c,d].remove(0,2) => [d]
Array.prototype.remove = function(from, to) {
  const rest = this.slice(((to || from) + 1) || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

Array.prototype.removeObj = function(obj) {
  const i = this.indexOf(obj);
  if (~i) {
    this.remove(i);
    return true;
  } else {
    return false;
  }
};

Array.prototype.replaceFirst = function(obj, replacement) {
  return this[this.indexOf(obj)] = replacement;
};

Array.prototype.shuffle = function() {
  let top = this.length;
  if (top) {
    while (--top) {
      const current = Math.floor(Math.random() * (top + 1));
      const tmp = this[current];
      this[current] = this[top];
      this[top] = tmp;
    }
  }
  return this;
};

Array.prototype.randomElement = function() {
  return this[Math.floor(Math.random() * this.length)];
};

const ExtMath = {};

ExtMath.randomInt = max => Math.floor(Math.random() * max);

ExtMath.randomFloat = function(max) {
  if (max == null) { max = 1; }
  return Math.random() * max;
};

ExtMath.randomValue = function(a, b) {
  let max, min;
  if (a <= b) {
    min = a;
    max = b;
  } else {
    min = b;
    max = a;
  }
  return min + (Math.random() * (max - min));
};

ExtMath.randomGaussianIrwinHall = function(opts) {
  if (opts == null) { opts = {}; }
  if (opts.mean == null) { opts.mean = 0; }
  if (opts.deviation == null) { opts.deviation = 1; }

  // a 12th order Irwin-Hall distribution, which is a close approximation of a
  // standard normal distribution and is faster than other typical methods.
  let v = 0;
  for (let i = 1; i <= 12; i++) {
    v += (Math.random() - 0.5);
  }
  return (v * opts.deviation) + opts.mean;
};

ExtMath._haveNextNextGuassian = false;
ExtMath._nextNextGuassian = 0;
ExtMath.randomGaussianJava = function(opts) {
  if (opts == null) { opts = {}; }
  if (ExtMath._haveNextNextGaussian) {
    ExtMath._haveNextNextGaussian = false;
    return ExtMath._nextNextGaussian;
  } else {
    let v1, v2;
    let s = 0;
    while ((s >= 1) || (s === 0)) {
      v1 = (2 * Math.random()) - 1;   // between -1.0 and 1.0
      v2 = (2 * Math.random()) - 1;   // between -1.0 and 1.0
      s = (v1 * v1) + (v2 * v2);
    }
    const multiplier = Math.sqrt((-2 * Math.log(s))/s);
    ExtMath._nextNextGaussian = v2 * multiplier;
    ExtMath._haveNextNextGaussian = true;
    return v1 * multiplier;
  }
};

ExtMath.randomGaussian= function(opts) {
  // return ExtMath.randomGaussianIrwinHall(opts)
  if (opts == null) { opts = {}; }
  return ExtMath.randomGaussianJava(opts);
};

ExtMath.flip = () => ExtMath.randomInt(2);

ExtMath.HALF_PI = Math.PI / 2;
ExtMath.TWO_PI  = Math.PI * 2;

ExtMath.normalizeRads = t => t - (ExtMath.TWO_PI * Math.floor((t + Math.PI) / ExtMath.TWO_PI));

ExtMath.distanceSquared = function(p1, p2) {
  const dx = p1.x - p2.x;
  const dy = p1.y - p2.y;
  return ((dx*dx) + (dy*dy));
};

/*
  Given an object of default values:
  defaultOptions = {
    a: "a",
    b: "b",
    c: {
      d: "d",
      e: "e"
    }
  }

  and an object of options
  options = {
    a: "A",
    c: {
      d: "D"
      f: "F"
    }
  }

  this will set defaults for any undefined values, included those
  in nested objects:

  setDefaults(options, defaultOptions) = {
    a: "A",
    b: "b",
    c: {
      d: "D",
      e: "e",
      f: "F"
    }
  }
*/
function setDefaults(opts, defaults) {
  for (let p in defaults) {
    if (opts[p] === undefined) {
      opts[p] = defaults[p];
    } else if (typeof opts[p] === "object") {
      opts[p] = setDefaults(opts[p], defaults[p]);
    }
  }
  return opts;
}

/*
  Deep-copy an object
*/
function clone(obj) {
  if ((obj == null) || (typeof obj !== 'object')) {
    return obj;
  }

  const cloneObj = new obj.constructor();

  for (let key in obj) {
    cloneObj[key] = clone(obj[key]);
  }

  return cloneObj;
}

function showMessage(message, element, callback) {
  for (let oldBox of Array.from(document.getElementsByClassName("message-box"))) { oldBox.remove(); }

  const top   = element.offsetTop + 50;
  const width = 280;
  const left  = (element.offsetLeft + (element.offsetWidth/2)) - (width/2);

  const box = document.createElement('div');
  box.classList.add('message-box');
  box.setAttribute("style",
    `\
top: ${top}px;
left: ${left}px;
width: ${width}px;\
`
  );

  box.innerHTML = message;

  const button = document.createElement('div');
  button.classList.add('button');
  button.innerHTML = "Ok";
  button.addEventListener('click', function() {
    element.removeChild(box);
    if (callback) { return callback(); }
  });
  box.appendChild(button);

  return element.appendChild(box);
}

function stringify(obj){
  if ((obj == null) || (typeof obj !== 'object')) {
    return String(obj);
  }

  let str = "{ ";
  for (let key in obj) {
    str += String(key) + ": " + this.stringify(obj[key] + ", ");
  }

  return str.slice(0,str.length-2) + " }";
}

// sources is an array of objects, each which have a 'preload' property.
// the 'preload' property is an array of strings which will be treated as urls.
// The strings can be image paths or paths to json files specifying assets
// ex: preload([{preload: ["foo.jpg", "bar.png"]},{preload: ["baz.json"]}], function() {/**all done**/})
function preload(sources, callback){
  const statusContainer = document.createElement('div');
  statusContainer.classList.add('preload-message');
  const statusDom = document.createElement('div');
  statusDom.classList.add('text');
  statusDom.innerHTML = "Loading... 0% complete.";
  statusContainer.appendChild(statusDom);
  document.body.appendChild(statusContainer);

  const assets = [];
  for (let source of Array.from(sources)) {
    if (source.preload == null) { continue; }
    for (let asset of Array.from(source.preload)) {
      assets.push(asset);
    }
  }

  let numImages = null;

  const loader = new PIXI.AssetLoader(assets);

  loader.onProgress = function() {
    if (!numImages) {
      numImages = loader.loadCount + 1;
    }
    return statusDom.innerHTML = `Loading... ${Math.floor(((numImages-loader.loadCount)/numImages)*100)}%`;
  };
  loader.onComplete = function() {
    statusDom.innerHTML = "Loading complete!";
    return setTimeout(function() {
      callback();
      return document.body.removeChild(statusContainer);
    }
    , 10);
  };
  return loader.load();
};

function mixOf(base, ...mixins) {
  class Mixed extends base {}
  for (let i = mixins.length - 1; i >= 0; i--) { //earlier mixins override later ones
    const mixin = mixins[i];
    const mixinMethods = Object.getOwnPropertyNames( mixin.prototype );
    for (let name of mixinMethods) {
      const method = mixin.prototype[name];
      Mixed.prototype[name] = method;
    }
  }
  return Mixed;
}

export {
  ExtMath,
  setDefaults,
  clone,
  showMessage,
  stringify,
  preload,
  mixOf
};
