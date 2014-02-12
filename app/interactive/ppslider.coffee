# Based on the code here: http://jsfiddle.net/LucP/BPdKR/2/
# TODO We could probably convert this to not rely on jQuery...

`
var PPSliderClass;
(function ($) {

  PPSliderClass = function (el, opts) {
    if (typeof($) == 'undefined' || $ == null) {
      console.warn('jQuery not loaded! PPSlider is not supported');
      return;
    }
    var element = $(el);
    var options = opts;
    var isMouseDown = false;
    var currentVal = 0;

    element.wrap('<div/>')
    var container = $(el).parent();

    container.addClass('pp-slider');
    container.addClass('clearfix');
    var content = '<div class="pp-slider-min">-</div>';
    content    += '<div class="pp-slider-scale">';
    content    += '<div class="pp-slider-button"><div class="pp-slider-divies"></div></div>';
    content    += '<div class="pp-slider-tooltip"></div>';
    content    += '</div>';
    content    += '<div class="pp-slider-max">+</div>';
    container.append(content);

    if (typeof(options) != 'undefined' && typeof(options.hideTooltip) != 'undefined' && options.hideTooltip == true)
    {
      container.find('.pp-slider-tooltip').hide();
      container.addClass('noTooltip');
    }

    if (typeof(options.width) != 'undefined')
    {
      container.css('width',(options.width+'px'));
    }
    container.find('.pp-slider-scale').css('width',(container.width()-30)+'px');

    var startSlide = function (e) {
      if (e.originalEvent && e.originalEvent instanceof TouchEvent) {
        e.preventDefault();
      }
      isMouseDown = true;
      var pos = getMousePosition(e);
      startMouseX = pos.x;

      lastElemLeft = ($(this).offset().left - $(this).parent().offset().left);
      updatePosition(e);

      return false;
    };

    var getMousePosition = function (e) {
      //container.animate({ scrollTop: rowHeight }, options.scrollSpeed, 'linear', ScrollComplete());
      var posx = 0;
      var posy = 0;

      if (!e) var e = window.event;

      if (e.originalEvent && e.originalEvent  instanceof TouchEvent) {
        posx = e.originalEvent.changedTouches[0].pageX;
        posy = e.originalEvent.changedTouches[0].pageY;
      }
      else if (e.pageX || e.pageY) {
        posx = e.pageX;
        posy = e.pageY;
      }
      else if (e.clientX || e.clientY) {
        posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        posy = e.clientY + document.body.scrollTop  + document.documentElement.scrollTop;
      }

      return { 'x': posx, 'y': posy };
    };

    var updatePosition = function (e) {
      var pos = getMousePosition(e);

      var spanX = (pos.x - startMouseX);

      var newPos = (lastElemLeft + spanX)
      var upperBound = (container.find('.pp-slider-scale').width()-container.find('.pp-slider-button').width());
      newPos = Math.max(0,newPos);
      newPos = Math.min(newPos,upperBound);
      currentVal = Math.round((newPos/upperBound)*100,0);

      container.find('.pp-slider-button').css("left", newPos);
      container.find('.pp-slider-tooltip').html(currentVal+'%');
      container.find('.pp-slider-tooltip').css('left', newPos-6);
    };

    var updatePositionByValue = function (val) {
      currentVal = val;
      var upperBound = (container.find('.pp-slider-scale').width()-container.find('.pp-slider-button').width());
      var newPos = (val/100)*upperBound;

      container.find('.pp-slider-button').css("left", newPos);
      container.find('.pp-slider-tooltip').html(val+'%');
      container.find('.pp-slider-tooltip').css('left', newPos-6);
    };

    var moving = function (e) {
      if(isMouseDown){
        if (e.originalEvent && e.originalEvent instanceof TouchEvent) {
          e.preventDefault();
        }
        updatePosition(e);
        return false;
      }
    };

    var dropCallback = function (e) {
      if (isMouseDown) {
        if (e.originalEvent && e.originalEvent instanceof TouchEvent) {
          e.preventDefault();
        }
        isMouseDown = false;
        element.val(currentVal);
        element.trigger("change");
      }

    };

    updatePositionByValue(element.val());

    container.find('.pp-slider-button').bind('mousedown',startSlide);
    container.find('.pp-slider-button').bind('touchstart',startSlide);

    $(document).mousemove(function(e) { moving(e); });
    $(document).on('touchmove', function(e) { moving(e); });

    $(document).mouseup(function(e){ dropCallback(e); });
    $(document).on('touchend', function(e){ dropCallback(e); });

  };

  /*******************************************************************************************************/

  if (typeof($) == 'undefined' || $ == null) {
    console.warn('jQuery not loaded! PPSlider is not supported');
    return;
  }

  $.fn.PPSlider = function (options) {
    var opts = $.extend({}, $.fn.PPSlider.defaults, options);

    return this.each(function () {
        new PPSliderClass($(this), opts);
    });
  }

  $.fn.PPSlider.defaults = {
    width: 150,
    hideTooltip: true
  };


})(jQuery);
`
module.exports = PPSliderClass
