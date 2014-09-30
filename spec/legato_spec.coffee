'use strict'

sandbox = require( './utils' ).sandbox
_ = require 'lodash'

describe 'legato', ->
  legato = {}

  beforeEach ->
#    spyOn console, 'log' # prevent logs

    localRequire = (lib) ->
      if lib is 'lodash'
        return _
      else if lib is 'midi'
        return rtMidiMock
      else if lib is './legato'
        return midiLegatoMock
      else if lib is './legatoUtils'
        return legatoUtils
      else if lib is './legatoMidi'
        return midi
      else if lib is './legatoOSC'
        return legatoOSC
      else if lib is './legatoRouter'
        return legatoRouter
      else
        return {}

    rtMidiMockGlobals =
      console: console
      exports: {},
      spyOn: spyOn

    sandbox 'spec/rtMidiMock.coffee', rtMidiMockGlobals
    rtMidiMock = rtMidiMockGlobals.exports.rtMidiMock

    legatoUtils = sandbox 'lib/legatoUtils.coffee',
      console: console

    legatoRouter = sandbox 'lib/legatoRouter.coffee',
      console: console

    midiLegatoMock =
      ____: -> ->
        return true
      store: ->
        return true

    midi = sandbox 'lib/legatoMidi.coffee',
      console: console
      require: localRequire

    legatoOSC = sandbox 'lib/legatoOSC.coffee',
      console: console
      require: localRequire

    legato = sandbox 'lib/legato.coffee',
      console: console
      require: localRequire

  it 'should provide access to the midi and osc libraries', ->
    expect( legato.midi ).toBeDefined
    expect( legato.osc ).toBeDefined

  # TODO Testing around in, on, removeRoute, removeInput, init'