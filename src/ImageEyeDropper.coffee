class ImageEyeDropper
	constructor: (img, opts={})->
		@fnStack = {}
		@init(img, opts)

	init: (img, opts)->
		if(typeof img is 'string')
			if (imgObj = document.getElementById(img)) and imgObj.tagName is 'IMG' then img = imgObj
		@_loaded = false
		(@img = img).addEventListener 'load', ()=> @_imageLoaded()

	isReady: ()-> @_loaded

	_imageLoaded: ()->
		@canvas = document.createElement 'canvas'
		@canvas.width = @width = w = @img.width
		@canvas.height = @height = h = @img.height
		@ctx = @canvas.getContext '2d'
		@ctx.drawImage @img, 0, 0, w, h
		@data = @ctx.getImageData(0, 0, w, h).data

		@img.addEventListener 'click', (e)=> @imgClick(e)
		@img.addEventListener 'mousemove', (e)=> @imgMousemove(e)
		@_loaded = true

	colorFromPoint: (point)->
		i = pixelIndex = (point.y*@width + point.x)*4
		@hex = ImageEyeDropper.rgbToHex @rgb = [@data[i], @data[i+1], @data[i+2]]

	imgClick: (e)-> @trigger 'click', @hex, @rgb
	imgMousemove: (e)-> @trigger 'mousemove', @colorFromPoint(@cursor=@_getCursor e), @rgb

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
	on: (type, fn)-> (@fnStack[type] = @fnStack[type] ? []).push fn
	off: (type, fn)->
		fns = @fnStack[type]
		if fn?() then (fns.splice i,1 if func is fn) for func, i in fns
		else delete @fnStack[type]

ImageEyeDropper.rgbToHex = (rgb)->
	hex = []
	pushToHex = (val, i)->
		bit = (val - 0).toString(16)
		hex.push(_hex = if bit.length is 1 then ('0' + bit) else bit)
	pushToHex val, i for val, i in rgb
	'#' + hex.join ''

window.ImageEyeDropper = ImageEyeDropper
