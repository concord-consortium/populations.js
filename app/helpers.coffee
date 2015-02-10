# [a,b,c,d].remove(1) => [a,c,d]
# [a,b,c,d].remove(0,2) => [d]
Array::remove = (from, to) ->
  rest = this.slice((to || from) + 1 || this.length)
  this.length = if from < 0 then this.length + from else from
  return this.push.apply(this, rest)

Array::removeObj = (obj) ->
  i = this.indexOf(obj)
  if ~i
    this.remove(i)
    true
  else
    false

Array::replaceFirst = (obj, replacement) ->
  this[this.indexOf(obj)] = replacement

Array::shuffle = ->
  top = @length
  if top
    while (--top)
      current = Math.floor(Math.random() * (top + 1))
      tmp = this[current]
      this[current] = this[top]
      this[top] = tmp
  return this

Array::randomElement = ->
  return this[Math.floor Math.random() * @length]

window.ExtMath = {}

ExtMath.randomInt = (max) ->
  Math.floor Math.random() * max

ExtMath.randomFloat = (max=1) ->
  Math.random() * max

ExtMath.randomValue = (min, max) ->
  min + Math.random() * (max - min)

ExtMath.randomGaussianIrwinHall = (opts={}) ->
  opts.mean = 0 unless opts.mean?
  opts.deviation = 1 unless opts.deviation?

  # a 12th order Irwin-Hall distribution, which is a close approximation of a
  # standard normal distribution and is faster than other typical methods.
  v = 0
  for i in [1..12]
    v += (Math.random() - 0.5)
  return v * opts.deviation + opts.mean

ExtMath._haveNextNextGuassian = false
ExtMath._nextNextGuassian = 0
ExtMath.randomGaussianJava = (opts={}) ->
  if ExtMath._haveNextNextGaussian
    ExtMath._haveNextNextGaussian = false
    return ExtMath._nextNextGaussian
  else
    s = 0
    while s >= 1 or s is 0
      v1 = 2 * Math.random() - 1   # between -1.0 and 1.0
      v2 = 2 * Math.random() - 1   # between -1.0 and 1.0
      s = v1 * v1 + v2 * v2
    multiplier = Math.sqrt(-2 * Math.log(s)/s)
    ExtMath._nextNextGaussian = v2 * multiplier
    ExtMath._haveNextNextGaussian = true
    return v1 * multiplier

ExtMath.randomGaussian= (opts={}) ->
  # return ExtMath.randomGaussianIrwinHall(opts)
  return ExtMath.randomGaussianJava(opts)

ExtMath.flip = ->
  ExtMath.randomInt(2)

ExtMath.HALF_PI = Math.PI / 2
ExtMath.TWO_PI  = Math.PI * 2

ExtMath.normalizeRads = (t) ->
  t - ExtMath.TWO_PI * Math.floor((t + Math.PI) / ExtMath.TWO_PI)

module.exports =

  ###
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
  ###
  setDefaults: (opts, defaults) ->
    for p of defaults
      if (opts[p] is undefined)
        opts[p] = defaults[p]
      else if (typeof opts[p] is "object")
        opts[p] = @setDefaults(opts[p], defaults[p]);
    opts

  ###
    Deep-copy an object
  ###
  clone: (obj) ->
    if not obj? or typeof obj isnt 'object'
      return obj

    cloneObj = new obj.constructor()

    for key of obj
      cloneObj[key] = @clone obj[key]

    return cloneObj

  showMessage: (message, element, callback) ->
    oldBox.remove() for oldBox in document.getElementsByClassName("message-box")

    top   = element.offsetTop + 50
    width = 280
    left  = element.offsetLeft + (element.offsetWidth/2) - (width/2)

    box = document.createElement 'div'
    box.classList.add 'message-box'
    box.setAttribute "style",
      """
        top: #{top}px;
        left: #{left}px;
        width: #{width}px;
      """

    box.innerHTML = message

    button = document.createElement 'div'
    button.classList.add 'button'
    button.innerHTML = "Ok"
    button.addEventListener 'click', ->
      element.removeChild box
      if callback then callback()
    box.appendChild button

    element.appendChild box

  stringify: (obj)->
    if not obj? or typeof obj isnt 'object'
      return String(obj)

    str = "{ "
    for key of obj
      str += String(key) + ": " + @stringify obj[key] + ", "

    return str.slice(0,str.length-2) + " }"

  # sources is an array of objects, each which have a 'preload' property.
  # the 'preload' property is an array of strings which will be treated as urls.
  # The strings can be image paths or paths to json files specifying assets
  # ex: preload([{preload: ["foo.jpg", "bar.png"]},{preload: ["baz.json"]}], function() {/**all done**/})
  preload: (sources, callback)->
    statusContainer = document.createElement 'div'
    statusContainer.classList.add 'preload-message'
    statusDom = document.createElement 'div'
    statusDom.classList.add 'text'
    statusDom.innerHTML = "Loading... 0% complete."
    statusContainer.appendChild statusDom
    document.body.appendChild statusContainer

    assets = []
    for source in sources
      continue unless source.preload?
      for asset in source.preload
        assets.push asset

    numImages = null

    loader = new PIXI.AssetLoader(assets)

    loader.onProgress = ->
      if not numImages
        numImages = loader.loadCount + 1
      statusDom.innerHTML = "Loading... "+Math.floor((numImages-loader.loadCount)/numImages*100)+"%"
    loader.onComplete = ->
      statusDom.innerHTML = "Loading complete!"
      setTimeout ->
        callback()
        document.body.removeChild statusContainer
      , 10
    loader.load()

  mixOf: (base, mixins...) ->
    class Mixed extends base
    for mixin in mixins by -1 #earlier mixins override later ones
      for name, method of mixin::
        Mixed::[name] = method
    Mixed
