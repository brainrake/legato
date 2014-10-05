'use strict'

router = require( './router' )
utils = require( './utils' )
legatoMidi = require './midi'
midi = require 'midi'
omgosc = require 'omgosc'
legatoOSC = require './osc'
_ = require 'lodash'

utils.init _
router.init utils
legatoMidi.init router, utils, midi
legatoOSC.init utils, omgosc

@midi = legatoMidi
@osc = legatoOSC
# TODO Provide access to firmata and amixer

@init = ->
  utils.reinit()

@in = (prefix, input) ->
  return router.in prefix, input

@on = (path, callback) ->
  return router.on path, callback

@removeRoute = (id) ->
  @router.removeRoute id

@removeInput = (id, prefix) ->
  @router.removeInput id, prefix

@deinit = ->
  @router.deinit()