class Glitch
  
  data_canvas_el: 'canvas#data_canv'
  canvas_el: 'canvas#canv'
  fftData: null
  averages: []
  sineMemo: []
  sineMemo_20: []
  fps: 0
  now: null
  lastUpdate: (new Date)*1 - 1

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


    @data_canvas.height = if $(window).height() < 300 then $(window).height() else 400
    @data_canvas.width = if $(window).width() < 300 then $(window).width() else 300

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
    
    dCanvasWidth = @data_canvas.width
    dCanvasHeight = @data_canvas.height
    
    @data_ctx.drawImage(@video, 0,0, dCanvasWidth, dCanvasHeight)
    imageOutData = @data_ctx.getImageData(0, 0, dCanvasWidth, dCanvasHeight)

    data = imageOutData.data
    
    low_threshold = 100
    high_threshold = 40
    bend_threshold = 90
    low = 30
    high = 500
    mid = 250

    offset = if @fftData[high] > high_threshold then Math.round(@fftData[high]) else 0
    variation = if @fftData[low] > low_threshold then @fftData[low] else 0
    bend = if @fftData[mid] > bend_threshold then Math.round(@fftData[mid]) else 0
    
    offset_4 = offset*4
    variation_4 = variation*4

    currentLine = 1
    t = 0
    widest_pixel = (dCanvasWidth*4)-1

    for e,i in data
      
      if variation!=0
        data[i+variation] = data[i+(variation_4)] if ((i&3) is 0)
        # & 3 means % 4

      if offset!=0
        data[i-offset] = data[i+(offset_4)] if ((i&3) is 0)

      if bend != 0 and ((i&3) is 0)
        o = @sineMemo_20[t]
        data[i+1] = data[i+1+o]
      
      if bend != 0 and i % widest_pixel == 0
        t+=1
    
    @data_ctx.putImageData(imageOutData, 0, 0)
    @ctx.drawImage(@data_canvas, 0,0, canvasWidth, canvasHeight)

  fpscalc: ->
    thisFrameFPS = 1000 / ((@now=new Date) - @lastUpdate)
    @fps += (thisFrameFPS - @fps) / 10
    @lastUpdate = @now


  animate: ->
    webkitRequestAnimationFrame((=>@animate()))
    sounds.updateFFT(@fftData)
    @fuckup()
    @fpscalc()


  go: ->
    @initVid()
    @video.load()
    $(@video).on('loadedmetadata', (=>
      sounds.connectVideoAudio(@video)
      @video.playbackRate = 1
      @video.play()
      @fftData = new Uint8Array(sounds.analyser.frequencyBinCount)
      @animate()
      @fpsOut = $('#fps')
      setInterval((=>@fpsOut.text(Math.round(@fps))), 1000)
    ))

$(document).ready ->
  window.glitch = new Glitch()

# Nice tests:
# N4_jCeQuqqM