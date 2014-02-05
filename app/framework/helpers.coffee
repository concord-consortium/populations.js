# [a,b,c,d].remove(1) => [a,c,d]
# [a,b,c,d].remove(0,2) => [d]
Array::remove = (from, to) ->
  rest = this.slice((to || from) + 1 || this.length);
  this.length = if from < 0 then this.length + from else from;
  return this.push.apply(this, rest);

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
  top = @length;
  if top
    while (--top)
      current = Math.floor(Math.random() * (top + 1));
      tmp = this[current];
      this[current] = this[top];
      this[top] = tmp;
  return this;

Array::randomElement = ->
  return this[Math.floor Math.random() * @length]

window.ExtMath = {}

ExtMath.randomInt = (max) ->
  Math.floor Math.random() * max

ExtMath.randomValue = (min, max) ->
  min + Math.random() * (max - min)

ExtMath.flip = ->
  ExtMath.randomInt(2)

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

  showMessage: (message, element) ->
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
    box.appendChild button

    element.appendChild box

