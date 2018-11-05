// TODO: This file was created by bulk-decaffeinate.
// Sanity-check the conversion and remove this comment.
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

/*
  This is a simple helper library for dispatching custom events.
  While not strictly necessary, it also includes a polyfill for supporting
  event dispatching on browsers that don't have CustomEvent support.
*/

let Events;
module.exports = (Events = class Events {
  static dispatchEvent(type, data){
    if (document.dispatchEvent != null) {
      const evt = new CustomEvent(type, {detail: data});
      return document.dispatchEvent(evt);
    } else {
      return console.warn("document doesn't support dispatchEvent!");
    }
  }

  static addEventListener(type, callback){
    if (document.addEventListener != null) {
      return document.addEventListener(type, callback);
    } else {
      return console.warn("document doesn't support addEventListener!");
    }
  }
});

(function() {
  if (!window.CustomEvent || (typeof window.CustomEvent !== 'function')) {
    const CustomEvent = function( type, eventInitDict ) {
      const newEvent = document.createEvent('CustomEvent');
      newEvent.initCustomEvent(type,
        !!(eventInitDict && eventInitDict.bubbles),
        !!(eventInitDict && eventInitDict.cancelable),
        (eventInitDict ? eventInitDict.detail : null));
      return newEvent;
    };

    return window.CustomEvent = CustomEvent;
  }
})();


(function() {
  if (window.TouchEvent == null) {
    // Firefox > 24 doesn't expose TouchEvent to the desktop browser version. Create a class to prevent NPE's in the code.
    let TouchEvent;
    console.log("Shimming TouchEvent...");
    return window.TouchEvent = (TouchEvent = class TouchEvent {});
  }
})();
