_ = require 'lodash'

@amixer = require('./amixer').amixer
@midi = require('./midi')
@osc = require('./osc')

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
  console.info 'added input:', prefix

@on = (path, cb) ->
  path = '^' + path.replace /\:([^\/]*)/g, '([^/]*)'
  console.info 'added route:', path
  routes.push [path, cb]

@throttle = (delay, path, cb) =>
  @on path, _(cb).throttle(delay)
