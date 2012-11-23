Spine = require('spine')
Synth = require('models/synth')
$     = Spine.$

class Synths extends Spine.Controller
  constructor: (@context) ->
    super
    @synths = {}
    @compressor = @context.createDynamicsCompressor()
    #@compressor.threshold.value = -24
    @twobus = @context.createGainNode()
    @twobus.connect @compressor
    @compressor.connect @context.destination

    @frequency_map = {}

    Spine.bind 'synth:on', (freq) =>
      @on freq
    Spine.bind 'synth:off', (freq) =>
      @off freq
    Spine.bind 'synth:setfrequency', (etfreq, freq) =>
      @setFrequency etfreq, freq

  on: (freq) ->
    @synths[freq] = new Synth @context, @twobus, freq
    @synths[freq].setFrequency @frequencyMap(freq)
    @synths[freq].on()

  off: (freq) ->
    @synths[freq]?.off()

  frequencyMap: (freq) ->
    @frequency_map[freq] || freq

  setFrequency: (etfreq, freq) ->
    @frequency_map[etfreq] = freq
    # Set the frequency for existing synths.
    @synths[etfreq]?.setFrequency freq

module.exports = Synths
