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
  imageDataBuffer: null

  constructor: ->

    @data_canvas = $(@data_canvas_el)[0]
    @canvas = $(@canvas_el)[0]

    @initEvents()
    
    @data_ctx = @data_canvas.getContext('2d')
    @setCanvasSizes()

    @init_shader(@canvas)

  initEvents: ->
    $(window).on('resize', (=>
      console.log("RESIZE")
      @setCanvasSizes()))

  initVid: ->
    @video = document.querySelector('video')
  
  init_shader: (canvas_el)->
    papa = @
    @glsl_obj = Glsl(
                  canvas: @canvas
                  fragment: $("#glsl_script").text()
                  variables:
                    offset: 0
                    variation: 0
                    bend: 0
                    time: 0
                  init: (->
                    console.log('GLSL inited')
                  )
                  update: (time, delta) ->

                    if not papa.now
                      console.log("NOT NOW")
                      return false

                    papa.update_step(@)
                    #this.sync("balls")
                  
                )

  setCanvasSizes: ->  
    @canvas.height = $(window).height()
    @canvas.width = $(window).width()
 
    @canvasWidth = @canvas.width
    @canvasHeight = @canvas.height
    
    @dCanvasWidth = @data_canvas.width
    @dCanvasHeight = @data_canvas.height

  setFFTData: (data, averages) ->
    @fftData = data
    @averages = averages

  fpscalc: ->
    thisFrameFPS = 1000 / ((@now=new Date) - @lastUpdate)
    @fps += (thisFrameFPS - @fps) / 10
    @lastUpdate = @now

  animate: ->
    webkitRequestAnimationFrame((=>@animate()))
    sounds.updateFFT(@fftData)
    
    @data_ctx.drawImage(@video, 0,0, @dCanvasWidth, @dCanvasHeight)
    @imageDataBuffer = @data_ctx.getImageData(0, 0, @dCanvasWidth, @dCanvasHeight);

    @fpscalc()

  update_step: (shader) ->
    low_threshold = 100
    high_threshold = 40
    bend_threshold = 90
    low = 30
    high = 500
    mid = 250

    offset = if @fftData[high] > high_threshold then Math.round(@fftData[high]) else 0
    variation = if @fftData[low] > low_threshold then @fftData[low] else 0
    bend = if @fftData[mid] > bend_threshold then Math.round(@fftData[mid]) else 0

    shader.set('offset', offset)
    shader.set('variation', variation)
    shader.set('bend', bend)
    shader.set('imageData', @imageDataBuffer)

  go: ->
    @initVid()
    console.log('why')
    @video.load()
    $(@video).on('loadedmetadata', (=>
      sounds.connectVideoAudio(@video)
      @video.playbackRate = 1
      @video.play()
      @fftData = new Uint8Array(sounds.analyser.frequencyBinCount)
      @animate()
      @fpsOut = $('#fps')
      @glsl_obj.start()
      setInterval((=>@fpsOut.text(Math.round(@fps))), 1000)
    ))

$(document).ready(-> 
  window.glitch = new Glitch()
)

# Nice tests:
# N4_jCeQuqqM