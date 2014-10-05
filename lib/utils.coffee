'use strict'

class Utils

  # Used to create unique ids for inputs.
  inputsCreated = 0
  _ = null

  # Initialize the utilities class
  @init = (lodash) ->
    _ = lodash

  # Log a list of arguments to the console.
  @___ = ___ = -> console.log '[legato]', arguments...; arguments[0]

  @____ = (arg) -> -> ___ arg, arguments...; arguments[0]

  # A list of callbacks used to close midi and osc listeners.
  # TODO Make this private?
  @closet = {}

  # Generates an unique id string.
  # @return a unique id.
  @generateId = ->
    inputsCreated += 1
    return "/#{inputsCreated}"

  # Store a shutdown callback to the closet for later cleanup of opened ports.
  # @param callback {Function} A function to execute when shutting down (or reinitializing) legato.
  # @param id {int} The id of the shutdown method. If an id is not passed, one will be generated.
  @store = (callback, id) ->
    id = id ? @generateId()
    @closet[id] = callback
    return id

  @remove = (id) ->
    delete @closet[id]
    return true

  @clear = ->
    @closet = {}
    return true

  @callAll = ->
    cb() for prop, cb of @closet
    return true

  # Throttle the callback of a function.
  @throttle = (time, fn) -> _.throttle fn, time

  # Delay invocation of a callback.
  @delay = (time, fn) -> _.delay fn, time

  @bind = (cb, options) -> _.bind cb, options

@utils = Utils
