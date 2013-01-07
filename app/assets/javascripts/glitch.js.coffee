class Glitch
  
  data_canvas_el: 'canvas#data_canv'
  canvas_el: 'canvas#canv'
  fftData: null
  averages: []
  sineMemo: []
  sineMemo_20: []

  constructor: ->

    @initEvents()

    @data_canvas = $(@data_canvas_el)[0]
    @canvas = $(@canvas_el)[0]
    
    @ctx = @canvas.getContext('2d')
    @data_ctx = @data_canvas.getContext('2d')
    @setCanvasSizes()

    @initSineMemo()

  initSineMemo: ->
    for i in [-2000..2000]
      @sineMemo[i] = Math.round(Math.sin(i))

    for i in [-2000..2000]
      @sineMemo_20[i] = Math.round(Math.sin(i))*20

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

    offset = if @fftData[high] > threshold then Math.round(@fftData[high]) else 0
    variation = if @fftData[low] > threshold then @fftData[low] else 0
    bend = if @fftData[mid] > bend_threshold then Math.round(@fftData[mid]) else 0
        
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
        o = @sineMemo_20[t]
        data[i+1] = data[i+1+o]
      
      if bend != 0 and i % widest_pixel == 0
        t+=1
      
    @ctx.putImageData(imageData, 0, 0)

  animate: ->
    webkitRequestAnimationFrame((=>@animate()))
    sounds.updateFFT(@fftData)
    @fuckup()

  go: ->
    @initVid()
    @video.load()
    $(@video).on('loadedmetadata', (=>
      sounds.connectVideoAudio(@video)
      @video.playbackRate = 1
      @video.play()
      @fftData = new Uint8Array(sounds.analyser.frequencyBinCount)
      @animate())
    )

$(document).ready ->
  window.glitch = new Glitch()

# Nice tests:
# N4_jCeQuqqM