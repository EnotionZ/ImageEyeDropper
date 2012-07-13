ImageEyeDropper = (img, opts)->
	@fnStack = {}; @init(img, opts)

ImageEyeDropper.prototype = {
	init: (img, opts)->
		self = @

		if(typeof img is 'string')
			imgObj = document.getElementById img
			if imgObj and imgObj.tagName is 'IMG' then img = imgObj
		@img = img

		@img.addEventListener 'load', ()-> self._imageLoaded()
		@
	
	_imageLoaded: ()->
		@src = @img.getAttribute 'src'
		@width = w = @img.width
		@height = h = @img.height
		@canvas = document.createElement 'canvas'
		@canvas.width = w
		@canvas.height = h
		@ctx = @canvas.getContext '2d'
		@ctx.drawImage @img, 0, 0, w, h
		@data = @ctx.getImageData(0, 0, w, h).data

		self = @
		@img.addEventListener 'click', (e)-> self.imgClick(e)
		@img.addEventListener 'mousemove', (e)-> self.imgMousemove(e)

	colorFromPoint: (point)->
		i = pixelIndex = (point.y*@width + point.x)*4
		@color = @_RgbToHex [@data[i], @data[i+1], @data[i+2]]

	_RgbToHex: (rgb)->
		hex = []
		pushToHex = (val, i)->
			bit = (val - 0).toString(16)
			hex.push(_hex = if bit.length is 1 then ('0' + bit) else bit)
		pushToHex val, i for val, i in rgb
		'#' + hex.join ''

	imgClick: (e)->
		@trigger('click', @color)

	imgMousemove: (e)->
		@trigger 'mousemove', @colorFromPoint(@cursor=@_getCursor e)

	_getCursor: (e)->
		@_offset ?= @_getOffset()
		x: e.clientX - @_offset.x, y: e.clientY - @_offset.y

	_getOffset: ()->
		x = y = 0; obj = @img
		while obj.offsetParent
			x += obj.offsetLeft; y += obj.offsetTop
			obj = obj.offsetParent
		@_offset = x: x, y: y

	trigger: (type)->
		fns = @fnStack[type]; args = Array.prototype.slice.call arguments,1
		(func.apply @, args for func in fns) if fns?

	on: (type, fn)->
		@fnStack[type] = @fnStack[type] ? []
		@fnStack[type].push fn

	off: (type, fn)->
		fns = @fnStack[type]
		if fn?() then (fns.splice i,1 if func is fn) for func, i in fns
		else delete @fnStack[type]
}

window.ImageEyeDropper = ImageEyeDropper
