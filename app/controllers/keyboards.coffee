Spine = require('spine')
Keyboard = require('models/keyboard')

class Keyboards extends Spine.Controller
  className: 'keyboard'

  constructor: ->
    super

    @keyboard = new Keyboard(6)
    @keyboard.bind 'change', @render

    @render()

    Spine.bind 'key:down', (pitch) => @keyDown pitch
    Spine.bind 'key:up', (pitch) => @keyUp pitch

    $(document).keydown (e) =>
      keycode = e.which
      # keydown sends repeatedly if held down, so check it's state.
      return if @keyboard.keyState[keycode] is on

      @keyboard.keyState[keycode] = on
      # Move range up/down with -/+.
      if keycode is 189 or keycode is 187
        @moveOctaveWrapper keycode
      else if keycode.toString() in @keyboard.availableKeys()
        @keyDownFromKeyCode keycode

    $(document).keyup (e) =>
      keycode = e.which
      @keyboard.keyState[keycode] = off
      @keyUpFromKeyCode keycode if keycode.toString() in @keyboard.availableKeys()


  render: =>
    # Only allow a negative margin here to keep it inside the box.
    margin_left = -444  * (@keyboard.pos - 1)
    @keyboard.margin_left = if margin_left <= 0 then margin_left else 0
    @html require('views/keyboard')(@keyboard)

  keyDownFromKeyCode: (keycode) ->
    pitch = @keyboard.keyCodeToPitch keycode
    @keyDown pitch

  keyDownFromClick: (event) ->
    @keyDown event.target.id

  keyDown: (pitch) ->
    $key_el = $('#' + pitch)
    if $key_el.length > 0
      classes = $key_el.attr 'class'
      if classes.indexOf('white') isnt -1
        $key_el.addClass "white-down"
      else
        $key_el.addClass "black-down"
      @noteOn pitch

  keyUpFromKeyCode: (keycode) ->
    pitch = @keyboard.keyCodeToPitch keycode
    @keyUp pitch

  keyUpFromClick: (event) ->
    @keyUp event.target.id

  keyUp: (pitch) ->
    $key_el = $('#' + pitch)
    if $key_el.length > 0
      classes = $key_el.attr 'class'
      if classes.indexOf('white') isnt -1
        $key_el.removeClass "white-down"
      else
        $key_el.removeClass "black-down"
      @noteOff pitch

  noteOn: (keyid) ->
    Spine.trigger 'note:on', [keyid]

  noteOff: (keyid) ->
    Spine.trigger 'note:off', [keyid]

  moveOctaveWrapper: (keycode) ->
    switch keycode
      when 189
        @keyboard.updateAttribute 'pos', @keyboard.pos - 1
      when 187
        @keyboard.updateAttribute 'pos', @keyboard.pos + 1

module.exports = Keyboards
