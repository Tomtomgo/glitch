class Control

  constructor: ->
    @initEvents()

  initEvents: ->

    $("#gogo").click((=>
      @setYT()
      ))

    that = @

    $(".predefined").click((->
      that.setYT($(@).text())
      ))

    $("#controls").draggable()

    @connectControls()

  connectControls: ->
    $('#low_threshold').slider(
      min: 0
      max: 255
      slide: (e,ui)->
        window.glitch.low_threshold = ui.value
        $('#low_threshold_val').text(ui.value) )

    $('#mid_threshold').slider(
      min: 0
      max: 255
      slide: (e,ui)->
        window.glitch.mid_threshold = ui.value
        $('#mid_threshold_val').text(ui.value) )

    $('#red_shift').slider(
      min: 0
      max: 1
      step: 0.01
      slide: (e,ui)->
        window.glitch.red_shift = ui.value
        $('#red_shift_val').text(ui.value) )

    $('#green_shift').slider(
      min: 0
      max: 1
      step: 0.01
      slide: (e,ui)->
        window.glitch.green_shift = ui.value
        $('#green_shift_val').text(ui.value) )

    $('#blue_shift').slider(
      min: 0
      max: 1
      step: 0.01
      slide: (e,ui)->
        window.glitch.blue_shift = ui.value
        $('#blue_shift_val').text(ui.value) )

    $('#playback_rate').slider(
      min: 0.5
      max: 4
      step: 0.1
      slide: (e,ui)->
        window.glitch.setPlaybackRate(ui.value)
        $('#playback_rate_val').text(ui.value) )

  updateControls: ->
    $('#low_threshold').slider('value', window.glitch.low_threshold)
    $('#mid_threshold').slider('value', window.glitch.mid_threshold)
    $('#playback_rate').slider('value', window.glitch.playback_rate)
    $('#red_shift').slider('value', window.glitch.red_shift)
    $('#green_shift').slider('value', window.glitch.green_shift)
    $('#blue_shift').slider('value', window.glitch.blue_shift)

    $('#low_threshold_val').text($('#low_threshold').slider('value'))
    $('#mid_threshold_val').text($('#mid_threshold').slider('value'))
    $('#playback_rate_val').text($('#playback_rate').slider('value'))
    $('#red_shift_val').text($('#red_shift').slider('value'))
    $('#green_shift_val').text($('#green_shift').slider('value'))
    $('#blue_shift_val').text($('#blue_shift').slider('value'))

  setYT: (predefined)->
    if predefined
      youtubeId = predefined
    else
      youtubeId = $('#video_source').val()
    
    if youtubeId != ""

      YoutubeVideo(youtubeId, ((video)=>
        console.log(video)
        webmUrl = video.getSource("video/webm", "medium")
        if webmUrl != ""
          console.log(webmUrl['url'])
          $('#start').hide()
          $('video').attr('src', webmUrl['url'])
          @run()
          @updateControls()

      ))

  run: ->
    console.log('run!')
    window.glitch.go()

$(document).ready(->
  new Control())