
###
  This is a simple helper library for dispatching custom events.
  While not strictly necessary, it also includes a polyfill for supporting
  event dispatching on browsers that don't have CustomEvent support.
###

module.exports = class Events
  @dispatchEvent: (type, data)->
    if document.dispatchEvent?
      evt = new CustomEvent type, {detail: data}
      document.dispatchEvent evt
    else
      console.warn("document doesn't support dispatchEvent!")

  @addEventListener: (type, callback)->
    if document.addEventListener?
      document.addEventListener(type, callback)
    else
      console.warn("document doesn't support addEventListener!")

(->
  unless (window.CustomEvent and typeof window.CustomEvent is 'function')
    CustomEvent = ( type, eventInitDict ) ->
      newEvent = document.createEvent('CustomEvent')
      newEvent.initCustomEvent(type,
        !!(eventInitDict && eventInitDict.bubbles),
        !!(eventInitDict && eventInitDict.cancelable),
        (if eventInitDict then eventInitDict.details else null))
      return newEvent;

    window.CustomEvent = CustomEvent
)()