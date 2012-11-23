class TuningTools
  @fiveLimitRatios: ->
    0:  [1,1]
    1:  [25,24]
    2:  [9,8]
    3:  [6,5]
    4:  [5,4]
    5:  [4,3]
    6:  [45,32]
    7:  [3,2]
    8:  [8,5]
    9:  [5,3]
    10:  [9,5]
    11:  [15,8]

  @ratioToCentsOffset: (pitch, ratio, base = 0) ->
    pitch_class = pitch % 12
    f = ratio[0] / ratio[1]
    et_freq = @midiToEtFrequency pitch
    ji_freq = f * et_freq
    pitch_cents_offset = (3986.3 * ((Math.log(ji_freq) / Math.log(10)) - (Math.log(et_freq) / Math.log(10))))

    if pitch_cents_offset != 0
      pitch_cents_offset = pitch_cents_offset - (((pitch_class - base) % 12) * 100)

    pitch_cents_offset

  @offsetCents: (et_frequency, offset) ->
    et_frequency * Math.pow((Math.pow(2, 1/1200)), offset)

  @midiToEtFrequency: (pitch) ->
    pitch_class = pitch % 12
    #440 * (2**((pitch - 69) / 12.0))
    440 * (Math.pow(2, ((pitch - 69) / 12.0)))

module.exports = TuningTools
