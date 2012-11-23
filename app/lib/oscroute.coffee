Spine = require('spine')

class OscRoute
  constructor: ->
    @routes = []

  match: (route, path, options = {}) ->
    match = route.route.exec(path)
    return false unless match
    options.match = match
    params = match.slice(1)

    if route.names.length
      for param, i in params
        options[route.names[i]] = param

    route.callback.call(null, options) isnt false

  matchRoute: (path, options) ->
    for route in @routes
      if @match(route, path, options)
        return route
      return route if @match(route, path, options)

  add: (path, callback) ->
    if (typeof path is 'object' and path not instanceof RegExp)
      @add(key, value) for key, value of path
    else
      @routes.push(new Spine.Route(path, callback))

module.exports = OscRoute
