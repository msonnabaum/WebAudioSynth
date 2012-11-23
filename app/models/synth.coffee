Spine = require('spine')
EnvelopeGenerator = require('models/envelope_generator')

class Synth extends Spine.Model
  @configure 'Synth'

  @extend @Local

  constructor: (@context, @output, @frequency) ->
    @sample_rate = @context.sampleRate

    @SAMPLE_INTERVAL = 1 / @sample_rate
    @phase = 0.0
    @volume = .8
    @wave_form = 0
    @attack_time = .01
    @decay_time = .01
    @sustain_level = .7
    @envelope_generator = new EnvelopeGenerator(@SAMPLE_INTERVAL, @attack_time, @decay_time, @sustain_level)

    @analyzer = @context.createAnalyser()
    @analyzer.smoothingTimeConstant = 0.5
    @gain = @context.createGainNode()
    @panner = @context.createPanner()
    @lowpass = @context.createBiquadFilter()
    @lowpass.type = 0 # check this.
    @lowpass.frequency.value = 1300

    @node = @context.createJavaScriptNode 1024, 0, 2
    @node.onaudioprocess = (e) =>
      @fillAudioBuffer e

    @phaseModBuffer = []
    @timestamp = 0

    @setGain .4

    @node.connect @lowpass
    @lowpass.connect @panner
    @panner.connect @gain
    @gain.connect @analyzer

  sine: (i) ->
    Math.sin(i * Math.PI * 2.0)

  square: (i) ->
    i < 0.5 ? 1 : -1

  saw: (i) ->
    2 * (i - Math.round(i))

  triangle: (i) ->
    1 - 4 * Math.abs(Math.round(i) - i)
    #4 * ((i > 0.5 ?  1 - i : i ) - .25)

  setGain: (value, duration = 0.05) ->
    @gain.gain.value = value

  on: ->
    @gain.connect @output
    @envelope_generator.startAttack()

  off: ->
    @envelope_generator.startRelease()
    window.setTimeout =>
      @gain.disconnect()
    , @decay_time + 200

  setParam: (param, value) ->
    for key of @notes
      note = @notes[key]
      note.synth.gain.setValue value

  setFrequency: (@frequency) ->


  # Simpified methods from the moog google-doogle
  #
  # http://code.google.com/p/bob-moog-google-doodle/source/browse/oscillator.js

  # Fills the passed audio buffer with the tone represented by this oscillator.
  # @param {!AudioProcessingEvent} e The audio process event object.
  fillAudioBuffer: (e) ->
    buffer = e.outputBuffer
    left = buffer.getChannelData(1)
    right = buffer.getChannelData(0)

    for i in [0...buffer.length]
      envelope_coefficient = @envelope_generator.getNextAmplitudeCoefficient()
      progressInCycle = @advancedPhase(@frequency)

      level = @waveForm progressInCycle
      audioLevel = level * @volume * envelope_coefficient
      right[i] = audioLevel

      # In older versions of Chrome, Web Audio API always created two
      # channels even if you have requested monaural sound. However, this
      # is not the case in the newer (dev/canary) versions. This should
      # cover both.
      left[i] = right[i] if left

  advancedPhase: (frequency) ->
    cycleLengthInSeconds = 2 / frequency
    @phase -= cycleLengthInSeconds if @phase > cycleLengthInSeconds
    progressInCycle = @phase * frequency / 2
    @phase += @SAMPLE_INTERVAL
    progressInCycle

  @WaveForm = {
    TRIANGLE: 0
    SAWANGLE: 1
    RAMP: 2
    REVERSE_RAMP: 3
    SQUARE: 4
    FAT_PULSE: 5
    PULSE: 6
  }

  waveForm: (progressInCycle) ->
    switch @wave_form
      when Synth.WaveForm.TRIANGLE
        level = 4 * ((if progressInCycle > 0.5 then 1 - progressInCycle else progressInCycle) - .25)
      when Synth.WaveForm.SAWANGLE
        if progressInCycle < 0.5
          4 * progressInCycle - 1
        else
          -2 * progressInCycle + 1
      when Synth.WaveForm.RAMP
        2 * (progressInCycle - 0.5)
      when Synth.WaveForm.REVERSE_RAMP
        -2 * (progressInCycle - 0.5)
      when Synth.WaveForm.SQUARE
        progressInCycle < 0.5 ? 1 : -1
      when Synth.WaveForm.FAT_PULSE
        progressInCycle < 1 / 3 ? 1 : -1
      when Synth.WaveForm.PULSE
        progressInCycle < 0.25 ? 1 : -1

module.exports = Synth
