_ = require 'lodash'
@___ = ___ = -> console.log '[legato]', arguments...; arguments[0]

@amixer = require('./amixer').amixer
@midi = require('./midi')
@osc = require('./osc')

inputs = []

routes = [] # [ [path, cb]* ]

router = (path, val) ->
  #___ '[in]', path, val
  for [path_, cb] in routes
    if path.match path_ 
      ((_ cb).bind path:path, val:val) val 


@init = =>
  global.__legato?.close()
  ___ 'init'
  global.__legato = @ 

@close = =>
  ___ 'close'
  i.close() for i in inputs
  inputs.length = routes.length = 0
  global.__legato = undefined


@in = (prefix, input) ->
  inputs.push input (path, val) -> router prefix+path, val
  ___ '[in+] ', prefix

@on = (path, cb) ->
  path_ = '^' + path.replace /\:([^\/]*)/g, '([^/]*)'
  ___ '[route+]', path, '  ->', path_
  routes.push [path_, cb]

@throttle = (delay, fn) =>
  _(fn).throttle(delay)


