class ImageEyeDropper
	constructor: (img, opts={})->
		@fnStack = {}
		@opts = opts
		@load(img)

	load: (img)->
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

		canvas = document.createElement 'canvas'
		canvas.width = w = 64
		canvas.height = h = 64*@height/@width
		ctx = canvas.getContext '2d'
		ctx.drawImage @img, 0, 0, w, h
		rgbaData = ctx.getImageData(0, 0, w, h).data
		@analyzeData rgbaData, w*h

		if @opts.disableMouse isnt true
			@img.addEventListener 'click', (e)=> @imgClick(e)
			@img.addEventListener 'mousemove', (e)=> @imgMousemove(e)

	analyzeData: (d, len)->
		# pushes data to array of hsva
		# also push hsva to respective hue columns
		hsvData = []; buckets = []; _b = 24 # bucket size
		sat = 0; val = 0
		pushHsv = (i)->
			i = i*4
			hex = normalizeRgba(d[i], d[i+1], d[i+2]).toHex()
			hsva = color.hsva(hex).toArray()

			hue = hsva[0]*100; p = parseInt hue%_b, 10
			sat += hsva[1]
			val += hsva[2]

			buckets[p] = [] if typeof buckets[p] is 'undefined'
			buckets[p].push hsva if 0.92 > hsva[1] > 0.08 and 0.92 > hsva[2] > 0.08
			hsvData.push hsva
		pushHsv i for i in [0..len]
		@avgSat = sat/len; @avgVal = val/len

		# grab the index of the top three hue columns
		lengths = buckets.map (b) -> if b then b.length else 0
		popMax = ()->
			max = Math.max.apply null, lengths
			index = lengths.indexOf(max)
			lengths[index] = 0
			index
		indexPrimary1 = popMax()
		#indexPrimary2 = popMax()
		#indexPrimary3 = popMax()

		# get average hue color in column
		getAvgHueColor = (index)=>
			hue = 0
			hue += hsva[0] for hsva in buckets[index]
			hue /= buckets[index].length
			color.hsva {h: hue, s: @avgSat, v: @avgVal}
		color1 = getAvgHueColor indexPrimary1
		#color2 = getAvgHueColor indexPrimary2
		#color3 = getAvgHueColor indexPrimary3

		@color = color1
		@_loaded = true

		@opts.ready.call @ if typeof @opts.ready is 'function'


	getSwatches: (type, opts = {})->
		if !this.isReady() then return false

		angle = (opts.angle || 30)/360
		h = @color.toArray()[0]
		if type is 'analogous'
			a1 = @color.toHex()
			a2 = @color.h(h-angle).toHex()
			a3 = @color.h(h+angle).toHex()
			@color.h h
			return [a1, a2, a3]

		else if type is 'split-complementary'
			a1 = @color.toHex()
			a2 = @color.h(h+0.5-angle/2).toHex()
			a3 = @color.h(h+0.5+angle/2).toHex()
			@color.h h
			return [a1, a2, a3]

		else if type is 'tetradic'
			angle = (opts.angle || 60)/360
			a1 = @color.toHex()
			a2 = @color.h(h+angle).toHex()
			a3 = @color.h(h+0.5).toHex()
			a4 = @color.h(h+0.5+angle).toHex()
			@color.h h
			return [a1, a2, a3, a4]


	colorFromPoint: (point)->
		i = pixelIndex = (point.y*@width + point.x)*4
		@hex = '#'+normalizeRgba(@rgb = [@data[i], @data[i+1], @data[i+2]]).toHex()

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

normalizeRgba = (rgb)->
	if arguments.length > 1 then rgb = [arguments[0], arguments[1], arguments[2]]
	color.rgba {r: rgb[0]/255, g: rgb[1]/255, b: rgb[2]/255}

window.ImageEyeDropper = ImageEyeDropper
