Spine = require('spine')

class Keyboard extends Spine.Model
  @configure 'Keyboard', 'pos'

  constructor: (@octaves = 6) ->
    @keys = {}
    @keyState = {}
    @keyMap = {}
    @pos = Math.ceil(@octaves / 2) + 1
    offset = 64 - ((@octaves * 12) / 2)
    @pitch_offset = Math.round(offset / 12) * 12

    pitch = ((Math.ceil((8 - @octaves) / 2)) * 12)
    keyMapId = 0
    for i in @availableKeys()
      @keyMap[i] = pitch
      pitch++

  keyCodeToPitch: (keycode) ->
    @keyMap[keycode] + (12 * @pos)

  availableKeys: ->
    [
      '65' # a -> C
      '87' # w -> C#
      '83' # s -> D
      '69' # e -> D#
      '68' # d -> E

      '70' # f -> F
      '84' # t -> F#
      '71' # g -> G
      '89' # y -> G#
      '72' # h -> A
      '85' # u -> A#
      '74' # j -> B

      '75' # k -> C
      '79' # o -> C#
      '76' # l -> D
      '80' # p -> D#
      '186' # ; -> E

      '222' # ' -> F
      '221' # ] -> F#
    ]


module.exports = Keyboard
