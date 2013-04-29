_ = require 'lodash'
@___ = ___ = -> console.log '[legato]', arguments...; arguments[0]
@____ = (arg) -> -> ___ arg, arguments...; arguments[0]
for lib in 'amixer midi osc firmata'.split ' '
  @[lib] = require './'+lib

routes = []  # [ [path, cb]* ]

@dispatch = dispatch = (path, val) ->
  for [path_, cb] in routes
    if path.match path_
      (_.bind cb, path:path, val:val) val

@in = (prefix, input) ->
  ___ 'in+ ', prefix
  input (path, val) -> dispatch prefix+path, val

@on = (path, cb) ->
  path_ = '^' + (path.replace /\:([^\/]*)/g, '([^/]*)') + '$'
  ___ 'route+', path, '  ->', path_
  routes.push [path_, cb]

@throttle = (time, fn) -> _.throttle fn, time
@delay = (time, fn) -> _.delay fn, time

@closet = []
@init = =>
  global.__legato_deinit?()
  global.__legato_deinit = =>
    cb() for cb in @closet
    @closet.length = routes.length = 0
  ___ 'init'
  @
