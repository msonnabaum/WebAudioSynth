Spine = require('spine')
OscRoute = require('./oscroute')

class OscApi
  constructor: ->
    @router = new OscRoute
    @router.add key, value for key, value of @routes()
    # Just use global Spine events for now.

  trigger: (event, params...) ->
    Spine.trigger event, params...

  match: (route, message) ->
    @router.matchRoute route, message

  routes: ->
    # Plays a note when the duration is known.
    # /inst/0/note/60/play 120 3000
    "/inst/:id/note/:pitch/play": (params) =>
      @trigger 'note:play', params

    # Turns a note on.
    # /inst/0/note/60/on 120
    "/inst/:id/note/:pitch/on": (params) =>
      {pitch, velocity} = params
      @trigger 'key:down', pitch, velocity

    # Turns a note off.
    # /inst/0/note/60/off
    "/inst/:id/note/:pitch/off": (params) =>
      {pitch} = params
      @trigger 'key:up', pitch

    # Sets a pitch's tuning offset in cents.
    # /inst/0/note/60/tuning/offset/cents -13.686
    "/inst/:id/note/:pitch/tuning/offset/cents": (params) =>
      {pitch, args} = params
      @trigger 'note:tuning:offset:cents', pitch, args[0]

    # Sets a pitch's tuning offset from a ratio.
    "/inst/:id/note/:pitch/tuning/ratio": (ratio) =>
      {pitch, args} = params
      @trigger 'note:tuning:ratio', pitch, args[0..1]

    # Sets a pitch's tuning offset as a frequency.
    # /inst/0/note/60/tuning/offset/cents -13.686
    "/inst/:id/note/:pitch/tuning/offset/frequency": (offset) =>

module.exports = OscApi
