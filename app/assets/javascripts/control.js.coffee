class Control

  constructor: ->
    @initEvents()

  initEvents: ->

    $("#gogo").click((=>
      @setYT()
      @run()
      ))

    that = @

    $(".predefined").click((->
      that.setYT($(@).text())
      that.run()
      ))

    @connectControls()

  connectControls: ->
    $('#low_threshold').slider(
      min: 0
      max: 255
      slide: (e,ui)->
        window.glitch.low_threshold = ui.value)
    $('#mid_threshold').slider(
      min: 0
      max: 255
      slide: (e,ui)->
        window.glitch.mid_threshold = ui.value)
    $('#high_threshold').slider(
      min: 0
      max: 255
      slide: (e,ui)->
        window.glitch.high_threshold = ui.value)

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

      ))

  run: ->
    console.log('run!')
    window.glitch.go()

$(document).ready(->
  new Control())