'use strict'

sandbox = require( './utils' ).sandbox
_ = require 'lodash'

describe 'legato', ->
  legato = {}

  beforeEach ->
    spyOn console, 'log' # prevent logs

    localRequire = (lib) ->
      if lib is 'lodash'
        return _
      else if lib is 'midi'
        return rtMidiMock
      else if lib is './legato'
        return midiLegatoMock
      else if lib is './utils'
        return legatoUtils
      else if lib is './midi'
        return midi
      else if lib is './osc'
        return legatoOSC
      else if lib is './router'
        return legatoRouter
      else
        return {}

    rtMidiMockGlobals =
      console: console
      exports: {},
      spyOn: spyOn

    sandbox 'spec/rtMidiMock.coffee', rtMidiMockGlobals
    rtMidiMock = rtMidiMockGlobals.exports.rtMidiMock

    legatoUtils = sandbox( 'lib/utils.coffee',
      console: console
    )

    legatoRouter = sandbox( 'lib/router.coffee',
      console: console
    )

    midiLegatoMock =
      ____: -> ->
        return true
      store: ->
        return true

    midi = sandbox 'lib/midi.coffee',
      console: console

    legatoOSC = sandbox 'lib/osc.coffee',
      console: console

    legato = sandbox 'lib/legato.coffee',
      console: console
      require: localRequire

  it 'should provide access to the midi and osc libraries', ->
    expect( legato.midi ).toBeDefined
    expect( legato.osc ).toBeDefined

  # TODO Testing around in, on, removeRoute, removeInput, init'