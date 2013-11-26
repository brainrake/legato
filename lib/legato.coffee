'use strict'

_ = require 'lodash'

# TODO Should we be defining the public methods on module.exports?
# Why does legato not do that?

# Log a list of arguments to the console.
@___ = ___ = -> console.log '[legato]', arguments...; arguments[0]

@____ = (arg) -> -> ___ arg, arguments...; arguments[0]

# Make all required libraries accessible from the legato object.
for lib in 'amixer midi osc firmata'.split ' '
  @[lib] = require './'+lib

# Used to create unique ids for routes.
routesCreated = 0
# Used to create unique ids for inputs.
inputsCreated = 0

# A list of midi and osc routes with callbacks.
# TODO Make this private again?
@routes = {}

# A list of callbacks used to close midi and osc listeners.
# TODO Make this private?
@closet = {}

# Throttle the callback of a function.
@throttle = (time, fn) -> _.throttle fn, time

# Delay invocation of a callback.
@delay = (time, fn) -> _.delay fn, time

# Generates an unique id string.
# @return a unique id.
@generateId = ->
  inputsCreated += 1
  return "/#{inputsCreated}"

# Store a shutdown callback to the closet for later cleanup of opened ports.
# @param callback {Function} A function to execute when shutting down (or reinitializing) legato.
# @param id {int} The id of the shutdown method. If an id is not passed, one will be generated.
@store = (callback, id) ->
  id = id ? generateId()
  @closet[id] = callback
  return id

# Executes any callbacks that match the path specified.
# In other words, given the path '/input1/1/note/32', this method will call any callbacks
# that were registered to paths that match (such as '/input1/:/:/:').
# @param path {String} The path to test for matches. See legato.on for more info.
# @param val {int} The value of the event that triggered this dispatch.
@dispatch = dispatch = (path, val) ->
  for id, [path_, cb] of routes
    if path.match path_
      (_.bind cb, path:path, val:val) val
    else
      # I added this else branch to make sure that null entries are not added to the
      # results. I'm not sure if this is the desired behavior.

# Register a callback prefix. Each input/output port created is given a name and dispatches
# under that name. For example, creating a midi input port requires the following:
# legato.in( 'myMidiPortName', legato.midi.in( 1 ) )
# When messages come in on midi port 1, they will match routes that begin with '/myMidiPortName'
# @param prefix {String} (optional) The prefix to give this input.
# @param input {Function} A function that takes a callback to be executed when events occur on this port.
# @return {int} The id of the input created.
# TODO Do we want to guard against reserved prefix that would mess with our routing (ie. '/:')?
@in = (prefix, input) ->
  id = @generateId()

  if typeof(prefix) is 'function'
    input = prefix
    prefix = id

  ___ 'in+ ', prefix
  shutdown = input (path, val) ->
    dispatch prefix+path, val
  @store shutdown, id
  return id

# Setup a callback to be called based on the path passed.
# @param path {String} The path to match against when input events occur.
# Paths are specified as '/{inputName}/{channel}/{type}/{note}'
# {inputName} A named input created using legato.midi.in, legato.osc.in, etc.
# {channel} A midi channel
# {type} The type of midi event (note or cc)
# {note} The note to listen for. ex: 36 = c3 (http://www.midimountain.com/midi/midi_note_numbers.html)
# TODO Document the path structure for osc, firmata and amixer
#
# @param cb {Function} The callback function to execute when matching events occur.
@on = (path, cb) ->
  path_ = '^' + (path.replace /\:([^\/]*)/g, '([^/]*)') + '$'
  ___ 'route+ ', path, '  ->', path_
  routesCreated += 1
  routes[routesCreated] = [path_, cb]
  return routesCreated

# Remove a route from legato.
# @param id {number} The id of the route to remove (returned from the call to legato.on).
@removeRoute = (id) ->
  ___ 'route- ', id
  delete routes[id]

# Remove an input listener and any associated routes.
# @param id {int} The id of the input to removed (returned from the call to legato.in).
# @param prefix {String} If a custom prefix was used to create this input and you wish to remove
#     routes assocated with that prefix, pass the prefix as well. If the prefix is not removed,
#     then routes associated to that prefix will remain (which may be desired in some cases).
@removeInput = (id, prefix) ->
  ___ 'in- ', id, prefix
  for routeId, [route, cb] of @routes
    if route.indexOf("^#{id}") is 0
      @removeRoute routeId
    if prefix? && route.indexOf("^#{prefix}") is 0
      @removeRoute routeId
  delete closet[id]

# Remove any registered midi and osc port listeners.
# TODO Is it ok to remove this method from the global scope? Should I put it back in the global space
# so we're not changing things unnecessarily?
@deinit = ->
  # Call each of the shutdown callbacks in the closet.
  cb() for prop, cb of @closet
  # Reset both the closet and the routes.
  @closet = {}
  @routes = {}

@init = ->
  @deinit()
  ___ 'init'
  return this
