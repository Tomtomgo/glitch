class SineWave

  constructor: ->
    @context = new webkitAudioContext()
    @node = @context.createJavaScriptNode(1024, 1, 1)
    @sample_rate = @context.sampleRate
    @frequency = 1000
    @node = @context.createJavaScriptNode(2048, 1, 1)
    @x=0
    @node.onaudioprocess = (e) =>
      @process e

  process: (e) ->

    data = e.outputBuffer.getChannelData(0)
    phaseIncrement = 2.0 * Math.PI * @frequency / @sample_rate
    i = 0

    while i < data.length
      @x += phaseIncrement
      data[i] = (0.5 * Math.sin(@x))
      i++

  setFrequency: (freq) ->
    @frequency = freq
  
  play: ->
    console.log "Playing"
    @node.connect @context.destination

$(document).ready ->
  window.sw = new SineWave()