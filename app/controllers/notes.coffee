Spine = require('spine')
Note = require('models/note')
TuningTools = require('lib/tuning_tools')
$ = Spine.$

class Notes extends Spine.Controller
  @include TuningTools

  constructor: ->
    @notes = {}
    Spine.bind 'note:play', (keyid) =>
      unless @notes[keyid]?
        @notes[keyid] = new Note(keyid)
      note = @notes[keyid]
      note.on()

    Spine.bind 'note:on', (pitch) => @noteOn pitch
    Spine.bind 'note:off', (pitch) => @noteOff pitch
    Spine.bind 'note:tuning:offset:cents', (pitch, offset) =>
      @tuningOffsetCents pitch, offset
    Spine.bind 'note:tuning:ratio', (pitch, ratio) =>
      @tuningRatio pitch, ratio
    Spine.bind 'note:clearall', => @allOff()

  noteOn: (keyid) ->
    unless @notes[keyid]?
      @notes[keyid] = new Note(keyid)
    note = @notes[keyid]
    note.on()

  noteOff: (keyid) ->
    @notes[keyid]?.off()

  tuningOffsetCents: (pitch, offset) ->
    @colorPitches pitch, offset
    @getNote(pitch).offsetCents offset

  tuningRatio: (pitch, ratio) ->
    offset = @ratioToCentsOffset pitch, ratio
    @colorPitches pitch, offset
    @getNote(pitch).offsetCents offset

  getNote: (pitch) ->
    @notes[pitch] = new Note(pitch) unless @notes[pitch]?
    @notes[pitch]

  allOff: ->
    #@notes[pitch].off() for pitch of @notes
    # For now, go through all possible notes in case there's a leak.
    for pitch in [0..167]
      @notes[pitch] = new Note(pitch) unless @notes[pitch]?
      @notes[pitch].off()

    null

  # Adds colors to keys to show tuning offsets more clearly.
  colorPitches: (pitch, offset) ->
    r = g = b = 255
    if offset isnt 0
      color_offset = @scaleRange Math.abs(offset), 0, 100, 255, 0

      g = Math.floor color_offset
      if offset > 0
        b = Math.floor color_offset
      else
        r = Math.floor color_offset

    $el = $("##{pitch}.key")
    if $el.hasClass 'white'
      $el.css('background-color', "rgb(#{r},#{g},#{b})")
    else
      $el.css('background', "-webkit-linear-gradient(top left, #1D1D1F 0%, rgb(#{r - 180},#{g - 180},#{b - 180}) 81%)")

  scaleRange: (input, oldMin, oldMax, newMin, newMax) ->
    (input / ((oldMax - oldMin) / (newMax - newMin))) + newMin

module.exports = Notes
