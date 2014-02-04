
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
  unless window.CustomEvent
    CustomEvent = ( event, params )->
      params = params || { bubbles: false, cancelable: false, detail: undefined }
      evt = document.createEvent( 'CustomEvent' );
      evt.initCustomEvent( event, params.bubbles, params.cancelable, params.detail )
      return evt

    CustomEvent.prototype = window.CustomEvent.prototype

    window.CustomEvent = CustomEvent
)()
