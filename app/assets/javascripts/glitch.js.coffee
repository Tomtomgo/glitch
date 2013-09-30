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

  # Settable vars
  low_threshold: 150
  mid_threshold: 150
  playback_rate: 1
  red_shift: 0.5
  green_shift: 0.5
  blue_shift: 0.5
  loop_state: 'waiting'
  loop_in: null
  loop_out: null
  mirror: false

  constructor: ->

    @initEvents()

    @data_canvas = $(@data_canvas_el)[0]
    @canvas = $(@canvas_el)[0]
    
    @ctx = @canvas.getContext('2d')
    @data_ctx = @data_canvas.getContext('2d')
    @setCanvasSizes()

    @initSineMemo()

  setPlaybackRate: (rate) ->
    @playback_rate = rate
    @video.playbackRate = @playback_rate

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
    
    low = 30
    mid = 250

    variation = if @fftData[low] > @low_threshold then Math.round(150-@fftData[low]) else 0
    bend = if @fftData[mid] > @mid_threshold then Math.round(150-@fftData[mid]) else 0
    
    red_stay = 1 - @red_shift
    green_stay = 1 - @red_shift
    blue_stay = 1 - @red_shift

    # iteration vars
    t = 0
    line_max_index = Math.round((dCanvasWidth)*4)
    line_half_index = Math.round(line_max_index / 2)
    current_line = 0
    skip_it = 0

    for i in [0..data.length] by 1 # e,i in data #

      if skip_it > 0
        skip_it -= 1
        continue

      if (i % line_max_index == 0)
        current_line += 1
        middle = ((current_line) * line_max_index)-line_half_index
      
      if @mirror and i >= middle
        index = ((middle)-(i-middle))
        data[i] = data[index]
        data[i+1] = data[index+1]
        data[i+2] = data[index+2]
        data[i+3] = data[index+3]
        skip_it=3
      else if variation!=0
          data[i-variation] = (data[i+variation]*@red_shift)+(data[i]*red_stay) if ((i&3) is 0)
          data[i-variation] = (data[i+variation]*@green_shift)+(data[i]*green_stay) if ((i&3) is 1)
          data[i-variation] = (data[i+variation]*@blue_shift)+(data[i]*blue_stay) if ((i&3) is 2)
          # & 3 means % 4

        # Horizontal lines
        if bend != 0

          if (i&3) is 3
            data[i] = data[i+bend+@sineMemo_20[t]]
        
          if i/4 % line_max_index == 0
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
      #@video.currentTime = 100
      #@video.playbackRate = -0.9
      @video.play()
      @fftData = new Uint8Array(sounds.analyser.frequencyBinCount)
      @animate()
      @fpsOut = $('#fps')
      setInterval((=>@fpsOut.text(Math.round(@fps))), 1000)
      #setInterval((=>@video.currentTime=30), 500)
    ))

  hitLoop: ->
    v = $(@video)[0]
    
    if @loop_state is 'looping'
      $(@video).unbind('timeupdate.loops')
      @loop_state = 'waiting'
      return "Loop IN"
    else if @loop_state is 'waiting'
      @loop_in = v.currentTime
      @loop_state = 'looped_in'
      return "Loop OUT"
    else if @loop_state is 'looped_in' 
      @loop_out = v.currentTime
      @loop_state = 'looping'
      @addLoop()
      return "STOP"

  mirrorIt: ->
    if @mirror
      @mirror = false
      return "MIRROR"
    else
      @mirror = true
      return "UNMIRROR"


  addLoop: ->
    that=@
    console.log(@loop_out)
    $(@video).bind('timeupdate.loops', (->
      if @currentTime > that.loop_out
        @currentTime = that.loop_in
    ))

$(document).ready ->
  window.glitch = new Glitch()

# Nice tests:
# N4_jCeQuqqM