class Glitch
  
  data_canvas_el: 'canvas#data_canv'
  canvas_el: 'canvas#canv'
  fftData: []
  averages: []
  sineMemo: []

  constructor: ->

    @initEvents()

    @data_canvas = $(@data_canvas_el)[0]
    @canvas = $(@canvas_el)[0]
    
    @ctx = @canvas.getContext('2d')
    @data_ctx = @data_canvas.getContext('2d')
    @setCanvasSizes()

    @initSineMemo()

  initSineMemo: ->
    for i in [0..2000]
      @sineMemo[i] = Math.round(Math.sin(i))

  setCanvasSizes: ->  
    @canvas.height = $(window).height()
    @canvas.width = $(window).width()
    @data_canvas.height = $(window).height()
    @data_canvas.width = $(window).width()

  setFFTData: (data, averages) ->
    @fftData = data
    @averages = averages

  initEvents: ->
    $(window).on('resize', (=>
      console.log("RESIZE")
      @setCanvasSizes()))

  initCam: ->
    window.URL = window.URL || window.webkitURL
    navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia

    @video = document.querySelector('video')
    
    navigator.getUserMedia {audio: true, video: true}, (stream) =>
      @video.src = window.URL.createObjectURL(stream)
      sounds.connectAudio(stream)

  initVid: ->
    @video = document.querySelector('video')
        
  fuckup: ->

    sounds.updateFFT()

    canvasWidth = @canvas.width
    canvasHeight = @canvas.height
    
    #@data_ctx.drawImage(@video, 0,0, canvasWidth, canvasHeight)
    @ctx.drawImage(@video, 0,0, canvasWidth, canvasHeight)
    imageData = @ctx.getImageData(0, 0, canvasWidth, canvasHeight)
    #imageOutData = @ctx.getImageData(0, 0, canvasWidth, canvasHeight)

    data = imageData.data
    #outData = imageOutData.data
    
    threshold = 100
    bend_threshold = 100
    low = 30
    high = 500
    mid = 250

    if @fftData[high] > threshold
      offset = Math.round(@fftData[high])
    else
      offset = 0

    if @fftData[low] > threshold
      variation = @fftData[low]
    else 
      variation = 0

    if @fftData[mid] > bend_threshold
      bend = Math.round(@fftData[mid])
    else 
      bend = 0
    
    offset_4 = offset*4
    variation_4 = variation*4

    currentLine = 1
    t = 0
    widest_pixel = (canvasWidth*4)

    for e,i in data

      if variation!=0
        data[i] = data[i+(variation_4)] if i%2==0

      if offset!=0
        data[i-offset] = data[i+(offset_4)] if i%4==0

      if bend != 0 and i%4==0
        o = (@sineMemo[t]*5)*4
        #data[i] = data[i+o]
        data[i+1] = data[i+1+o]
      
      if bend != 0 and i % widest_pixel == 0
        t+=1
      
    @ctx.putImageData(imageData, 0, 0)

  animate: ->
    webkitRequestAnimationFrame((=>@animate()))
    @fuckup()

  go: ->
    @initVid()
    @video.load()
    $(@video).on('loadedmetadata', (=>
      sounds.connectVideoAudio(@video)
      @video.playbackRate = 1
      @video.play()
      @animate())
    )

$(document).ready ->
  window.glitch = new Glitch()

# Nice tests:
# N4_jCeQuqqM