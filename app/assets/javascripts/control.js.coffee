class Control

  constructor: ->
    @initEvents()

  initEvents: ->

    $("#gogo").click((=>
      @setYT()
      @run()
      ))

  setYT:->
    youtubeId = $('#video_source').val()
    
    if youtubeId != ""

      YoutubeVideo(youtubeId, ((video)=>
        console.log(video)
        webmUrl = video.getSource("video/webm", "medium")
        if webmUrl != ""
          console.log(webmUrl['url'])
          $('#controls').hide()
          $('video').attr('src', webmUrl['url'])
          @run()

      ))

  run: ->
    console.log('run!')
    window.glitch.go()

$(document).ready(->
  new Control())