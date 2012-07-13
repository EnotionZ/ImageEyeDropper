// Generated by CoffeeScript 1.3.3
(function() {
  var ImageEyeDropper;

  ImageEyeDropper = function(img, opts) {
    this.fnStack = {};
    return this.init(img, opts);
  };

  ImageEyeDropper.prototype = {
    init: function(img, opts) {
      var imgObj, self;
      self = this;
      if (typeof img === 'string') {
        imgObj = document.getElementById(img);
        if (imgObj && imgObj.tagName === 'IMG') {
          img = imgObj;
        }
      }
      this.img = img;
      this.img.addEventListener('load', function() {
        return self._imageLoaded();
      });
      return this;
    },
    _imageLoaded: function() {
      var h, self, w;
      this.src = this.img.getAttribute('src');
      this.width = w = this.img.width;
      this.height = h = this.img.height;
      this.canvas = document.createElement('canvas');
      this.canvas.width = w;
      this.canvas.height = h;
      this.ctx = this.canvas.getContext('2d');
      this.ctx.drawImage(this.img, 0, 0, w, h);
      this.data = this.ctx.getImageData(0, 0, w, h).data;
      self = this;
      this.img.addEventListener('click', function(e) {
        return self.imgClick(e);
      });
      return this.img.addEventListener('mousemove', function(e) {
        return self.imgMousemove(e);
      });
    },
    colorFromPoint: function(point) {
      var i, pixelIndex;
      i = pixelIndex = (point.y * this.width + point.x) * 4;
      return this.color = this._RgbToHex([this.data[i], this.data[i + 1], this.data[i + 2]]);
    },
    _RgbToHex: function(rgb) {
      var hex, i, pushToHex, val, _i, _len;
      hex = [];
      pushToHex = function(val, i) {
        var bit, _hex;
        bit = (val - 0).toString(16);
        return hex.push(_hex = bit.length === 1 ? '0' + bit : bit);
      };
      for (i = _i = 0, _len = rgb.length; _i < _len; i = ++_i) {
        val = rgb[i];
        pushToHex(val, i);
      }
      return '#' + hex.join('');
    },
    imgClick: function(e) {
      return this.trigger('click', this.color);
    },
    imgMousemove: function(e) {
      return this.trigger('mousemove', this.colorFromPoint(this.cursor = this._getCursor(e)));
    },
    _getCursor: function(e) {
      var _ref;
      if ((_ref = this._offset) == null) {
        this._offset = this._getOffset();
      }
      return {
        x: e.clientX - this._offset.x,
        y: e.clientY - this._offset.y
      };
    },
    _getOffset: function() {
      var obj, x, y;
      x = y = 0;
      obj = this.img;
      while (obj.offsetParent) {
        x += obj.offsetLeft;
        y += obj.offsetTop;
        obj = obj.offsetParent;
      }
      return this._offset = {
        x: x,
        y: y
      };
    },
    trigger: function(type) {
      var args, fns, func, _i, _len, _results;
      fns = this.fnStack[type];
      args = Array.prototype.slice.call(arguments, 1);
      if (fns != null) {
        _results = [];
        for (_i = 0, _len = fns.length; _i < _len; _i++) {
          func = fns[_i];
          _results.push(func.apply(this, args));
        }
        return _results;
      }
    },
    on: function(type, fn) {
      var _ref;
      this.fnStack[type] = (_ref = this.fnStack[type]) != null ? _ref : [];
      return this.fnStack[type].push(fn);
    },
    off: function(type, fn) {
      var fns, func, i, _i, _len, _results;
      fns = this.fnStack[type];
      if (typeof fn === "function" ? fn() : void 0) {
        _results = [];
        for (i = _i = 0, _len = fns.length; _i < _len; i = ++_i) {
          func = fns[i];
          _results.push(func === fn ? fns.splice(i, 1) : void 0);
        }
        return _results;
      } else {
        return delete this.fnStack[type];
      }
    }
  };

  window.ImageEyeDropper = ImageEyeDropper;

}).call(this);
