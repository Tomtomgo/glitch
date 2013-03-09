class Sounds

  fx_on: false

  constructor: ->
    @context = new webkitAudioContext()

  connectAudio: (stream) ->
    source = @context.createMediaStreamSource(stream)
    source.connect(@context.destination)

  connectVideoAudio: (element) ->
    @source = @context.createMediaElementSource(element)
    
    @setupAnalyzer(@source)
    @addEffects(@source)
    @source.connect(@context.destination)

  addEffects: (source) ->
    
    @tuna = new Tuna(@context)
    @overdrive = new @tuna.Overdrive(
                    outputGain: 0.6
                    drive: 0.8
                    curveAmount: 0.4
                    algorithmIndex: 2
                )
    
    @delay = new @tuna.Delay(
                    feedback: 0.6,
                    delayTime: 250,
                    wetLevel: 0.5,
                    dryLevel: 0.5
            )

    @chorus = new @tuna.Chorus(
                  feedback: 0.5
                  delay: 0.1
                  rate: 0.75
                )

    @source.connect(@chorus.input)
    @chorus.connect(@overdrive.input)
    @chorus.connect(@delay.input)
    @overdrive.connect(@context.destination)
    @delay.connect(@context.destination)
    @fxOff()

  fxSet: ->
    if @fx_on
      @fxOff()
      @fx_on = false
      return "FX ON"
    else
      @fxOn()
      @fx_on = true
      return "FX OFF"

  fxOn: ->
    @chorus.bypass = 0
    @overdrive.bypass = 0
    @delay.bypass = 0

  fxOff:->
    @chorus.bypass = 1
    @overdrive.bypass = 1
    @delay.bypass = 1

  average: (arr) ->
    _.reduce(arr, ((memo, num) -> memo + num), 0) / arr.length

  setupAnalyzer: (source)->
    
    javascriptNode = @context.createJavaScriptNode(2048, 1, 1)
    javascriptNode.connect(@context.destination)

    @analyser = @context.createAnalyser()
    @analyser.smoothingTimeConstant = 0.2
    
    source.connect(@analyser)
    @analyser.connect(javascriptNode)
    console.log('Analyzer is set')

  updateFFT: (array) ->
    @analyser.getByteFrequencyData(array)  

$(document).ready ->
  window.sounds = new Sounds()