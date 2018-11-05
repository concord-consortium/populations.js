// Based on the code here: http://jsfiddle.net/LucP/BPdKR/2/
// TODO We could probably convert this to not rely on jQuery...
// coffeelint: disable=no_backticks


let PPSliderClass;
(function ($) {

  PPSliderClass = function (el, opts) {
    let startMouse, lastElemPos;

    if (typeof($) == 'undefined' || $ == null) {
      console.warn('jQuery not loaded! PPSlider is not supported');
      return;
    }
    const element = $(el);
    const options = opts;
    let isMouseDown = false;
    let currentVal = 0;

    element.wrap('<div/>');
    const container = $(el).parent();

    container.addClass('pp-slider');
    if (opts.vertical) {
      container.addClass('vertical');
    }
    container.addClass('clearfix');
    const minLabel = `<div class="pp-slider-min">${opts.minLabel}</div>`;
    const maxLabel = `<div class="pp-slider-max">${opts.maxLabel}</div>`;
    let content = '';
    if (opts.vertical) {
      content  += maxLabel;
    } else {
      content  += minLabel;
    }
    content    += '<div class="pp-slider-scale">';
    content    += '<div class="pp-slider-button';
    if (options.moveable) {
      content  += ' moveable';
    }
    content    += '"><div class="pp-slider-divies"></div></div>';
    content    += '<div class="pp-slider-tooltip"></div>';
    content    += '</div>';
    if (opts.vertical) {
      content  += minLabel;
    } else {
      content  += maxLabel;
    }
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
    if (typeof(options.height) != 'undefined')
    {
      container.css('height',(options.height+'px'));
    }
    if (opts.vertical) {
      container.find('.pp-slider-scale').css('height',(container.height()-30)+'px');
    } else {
      container.find('.pp-slider-scale').css('width',(container.width()-30)+'px');
    }

    const startSlide = function (e) {
      if (!options.moveable) {
        return true;
      }
      if (e.originalEvent && e.originalEvent instanceof TouchEvent) {
        e.preventDefault();
      }
      isMouseDown = true;
      const pos = getMousePosition(e);
      if (options.vertical) {
        startMouse = pos.y;
        lastElemPos = ($(this).offset().top - $(this).parent().offset().top);
      } else {
        startMouse = pos.x;
        lastElemPos = ($(this).offset().left - $(this).parent().offset().left);
      }

      updatePosition(e);

      return false;
    };

    var getMousePosition = function (e) {
      let posx = 0;
      let posy = 0;

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

    const positionSlider = function(newPos, currentVal) {
      if (options.vertical) {
        container.find('.pp-slider-button').css("top", newPos);
        container.find('.pp-slider-tooltip').html(currentVal+'%');
        container.find('.pp-slider-tooltip').css('top', newPos-6);
      } else {
        container.find('.pp-slider-button').css("left", newPos);
        container.find('.pp-slider-tooltip').html(currentVal+'%');
        container.find('.pp-slider-tooltip').css('left', newPos-6);
      }
    };

    var updatePosition = function (e) {
      const pos = getMousePosition(e);
      let newPos, upperBound;
      if (options.vertical) {
        const spanY = (pos.y - startMouse);
        newPos = (lastElemPos + spanY);
        upperBound = (container.find('.pp-slider-scale').height()-container.find('.pp-slider-button').height());
      } else {
        const spanX = (pos.x - startMouse);
        newPos = (lastElemPos + spanX);
        upperBound = (container.find('.pp-slider-scale').width()-container.find('.pp-slider-button').width());
      }
      newPos = Math.max(0,newPos);
      newPos = Math.min(newPos,upperBound);
      currentVal = Math.round((newPos/upperBound)*100,0);
      if (options.vertical) {
        // inverted when vertical
        currentVal = 100 - currentVal;
      }

      positionSlider(newPos, currentVal);
    };

    const updatePositionByValue = function (val) {
      currentVal = val;
      let upperBound, newPos;
      if (options.vertical) {
        upperBound = (container.find('.pp-slider-scale').height()-container.find('.pp-slider-button').height());
        newPos = ((100-val)/100)*upperBound;
      } else {
        upperBound = (container.find('.pp-slider-scale').width()-container.find('.pp-slider-button').width());
        newPos = (val/100)*upperBound;
      }

      positionSlider(newPos, val);
    };

    const moving = function (e) {
      if(isMouseDown){
        if (e.originalEvent && e.originalEvent instanceof TouchEvent) {
          e.preventDefault();
        }
        updatePosition(e);
        return false;
      }
    };

    const dropCallback = function (e) {
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

    return {
      updatePositionByValue
    };

  };

  /*******************************************************************************************************/

  if (typeof($) == 'undefined' || $ == null) {
    console.warn('jQuery not loaded! PPSlider is not supported');
    return;
  }

  $.fn.PPSlider = function (options) {
    const opts = $.extend({}, $.fn.PPSlider.defaults, options);

    let ret;
    this.each(function () {
        ret = new PPSliderClass($(this), opts);
    });
    return ret;
  };

  $.fn.PPSlider.defaults = {
    minLabel: '-',
    maxLabel: '+',
    moveable: true,
    vertical: false,
    hideTooltip: true
  };


})(jQuery);

module.exports = PPSliderClass;