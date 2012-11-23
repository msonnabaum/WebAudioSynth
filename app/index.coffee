require('lib/setup')

Spine = require('spine')
$ = Spine.$
Keyboards = require('controllers/keyboards')
AppSynths = require('controllers/synths')
Notes = require('controllers/notes')
OscApi = require('lib/api')
TuningTools = require('lib/tuning_tools')

window.AudioContext = window.AudioContext || window.webkitAudioContext || null
unless AudioContext
  throw new Error("AudioContext not supported!")

class App extends Spine.Controller
  @include TuningTools

  constructor: ->
    super
    @keyboards = new Keyboards
    @notes = new Notes
    @synths = new AppSynths(new AudioContext())
    @api = new OscApi

    @header  = $('<header />')
    @el.append(@header)

    @append @keyboards
    Spine.Route.setup()
    @initWebSockets()
    @setupButtons()

  initWebSockets: ->
    @socket = new WebSocket("ws://localhost:8081")
    @setupChannels()

  setupChannels: ->
    # Setup a recursive wildcard match since subscription paths can only end
    # in wildcards, and we need route-style placeholders.
    @socket.onmessage = (message) =>
      msg = JSON.parse message['data']
      @api.match msg['route'], msg

  addButton: (text, callback) ->
    callback = @[callback] if typeof callback is 'string'
    button = $('<button />').text(text)
    button.click(@proxy(callback))
    @header.append(button)
    button

  setupButtons: ->
    @addButton "Clear Notes", -> Spine.trigger 'note:clearall'
    @addButton "Equal Temperament", -> @equalTemperament()
    @addButton "5-limit JI", -> @fiveLimit()

  equalTemperament: ->
    for pitch in [0..167]
      Spine.trigger 'note:tuning:offset:cents', pitch, 0

  fiveLimit: ->
    ratios = @fiveLimitRatios()
    for pitch in [0..167]
      Spine.trigger 'note:tuning:ratio', pitch, ratios[(pitch % 12)]

module.exports = App
