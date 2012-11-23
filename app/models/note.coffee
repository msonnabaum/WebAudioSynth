Spine = require('spine')
Synth = require('models/synth')

class Note extends Spine.Model
  @configure "Note", "pitch", "freq", "etfreq", "synth"

  # @param {Number} pitch A midi note number.
  constructor: (@pitch) ->
    @etfreq = 440 * Math.pow(2, ((@pitch - 69)/12))
    @freq = @etfreq
    @synth = null
    @state = off

  on: ->
    @off() if @state
    @state = on
    # Use etfreq to prevent hanging notes who's frequency have changed.
    Spine.trigger 'synth:on', @etfreq

  off: ->
    @state = off
    Spine.trigger 'synth:off', @etfreq

  # Apply a tuning offset.
  #
  # @param {Number} offset An offset value in cents.
  offsetCents: (offset) ->
    @freq = @etfreq * Math.pow((Math.pow(2, 1/1200)), offset)
    Spine.trigger 'synth:setfrequency', @etfreq, @freq

module.exports = Note
