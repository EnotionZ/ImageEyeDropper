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
    hsvData = []; buckets = []; _b = 100 # bucket size
    sat = 0; val = 0
    buckets[i] = [] for i in [0.._b] # populate buckets with empty arrays

    for i in [0..len]
      do (i)->
        hex = normalizeRgba(d[i=i*4], d[i+1], d[i+2]).toHex()
        hsva = color.hsva(hex).toArray()

        hsvData.push hsva # store all pixel data in hsvData

        # grab color info within a certain saturation/value range
        if 0.90 > hsva[1] > 0.10 and 0.9 > hsva[2] > 0.1
          sat += hsva[1]; val += hsva[2]
          buckets[parseInt _b*hsva[0], 10].push hsva

    @avgSat = sat/len; @avgVal = val/len

		# grab the index of the top three hue columns
    lengths = buckets.map (b) -> b.length
    popMax = ()->
      max = Math.max.apply null, lengths
      lengths[index=lengths.indexOf(max)] = 0
      index
    indexPrimary = popMax()

    # get secondary and ensure it's at least 60 degrees away
    quarter = _b/6; secondary_tries=0
    while (diff=Math.abs((indexSecondary=popMax())-indexPrimary)) < quarter
      if ++secondary_tries > _b then break

    # get average hue color in column
    getAvgColor = (s, c)-> s.h += c[0]; s.s += c[1]; s.v += c[2]
    getAvgHueColor = (index)=>
      l = buckets[index].length
      s = {h: 0, s: 0, v: 0}
      getAvgColor s, hsva for hsva in buckets[index]
      hsl = {h: s.h/l || 0, s: s.s/l || 0, v: s.v/l || 0}
      color.hsva hsl
    color1 = getAvgHueColor indexPrimary
    color2 = getAvgHueColor indexSecondary

    @color = color1
    @color2 = color2
    @_loaded = true

    @opts.ready.call @ if typeof @opts.ready is 'function'


  getSwatches: (type, opts = {})->
    if !this.isReady() then return false

    angle = (opts.angle || 30)/360

    normalizeAngle = (a) ->
      a = a - parseInt(a)
      a = 1+a if a < 0
      a = 1-a if a > 1
      a

    # push secondary color
    colors = [@color2.toHex()]

    h = @color.toArray()[0]
    if type is 'analogous'
      colors.push @color.toHex()
      colors.push @color.h(normalizeAngle(h-angle)).toHex()
      colors.push @color.h(normalizeAngle(h+angle)).toHex()

    else if type is 'split-complementary'
      colors.push @color.toHex()
      colors.push @color.h(normalizeAngle(h+0.5-angle/2)).toHex()
      colors.push @color.h(normalizeAngle(h+0.5+angle/2)).toHex()

    else if type is 'tetradic'
      angle = (opts.angle || 60)/360
      colors.push @color.toHex()
      colors.push @color.h(h+angle).toHex()
      colors.push @color.h(normalizeAngle(h+0.5)).toHex()
      colors.push @color.h(normalizeAngle(h+0.5+angle)).toHex()

    @color.h h
    colors


  colorFromPoint: (point)->
    i = pixelIndex = (point.y*@width + point.x)*4
    @hex = '#'+normalizeRgba(@rgb = [@data[i], @data[i+1], @data[i+2]]).toHex()

  imgClick: (e)-> @trigger 'click', @hex, @rgb
  imgMousemove: (e)-> @trigger 'mousemove', @colorFromPoint(@cursor=@_getCursor e), @rgb

  _getCursor: (e)->
    if e.layerX?
      y = e.layerY - @img.offsetTop
      x = e.layerX - @img.offsetLeft
    else
      y = e.clientY
      x = e.clientX
    x: x, y: y

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
