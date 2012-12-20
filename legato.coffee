_ = require 'lodash'
@___ = ___ = -> console.log '[legato]', arguments...

@amixer = require('./amixer').amixer
@midi = require('./midi')
@osc = require('./osc')

___ 'init'

routes = []

router = (path_) ->
  #console.log 'router:', path_
  return (msg) ->
    for [path, cb] in routes
      ctx =
        val: msg
        path: path_
      _(cb).bind(ctx)(msg) if path_.match path

@in = (prefix, input) ->
  cb = (prefix) -> (path) -> router prefix+path
  input cb prefix
  ___ '[input]', prefix

@on = (path, cb) ->
  path = '^' + path.replace /\:([^\/]*)/g, '([^/]*)'
  ___ '[route]', path
  routes.push [path, cb]

@throttle = (delay, fn) =>
  _(fn).throttle(delay)


