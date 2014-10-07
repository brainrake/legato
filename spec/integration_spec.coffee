'use strict'

sandbox = require('./utils').sandbox
_ = require 'lodash'

rtMidiMock = {}
omgosc = {}
legato = {}
midi = {}
osc = {}
midiLegatoMock = {}
utils = {}
utilsClass = {}
router = {}
routerClass = {}

describe 'integration', ->

  beforeEach ->
    spyOn console, 'log' # prevent logs

    localRequire = (lib) ->
      if lib is 'lodash'
        return _
      else if lib is 'midi'
        return rtMidiMock
      else if lib is 'omgosc'
        return omgosc
      else if lib is './legato'
        return midiLegatoMock
      else if lib is './utils'
        return utilsClass
      else if lib is './router'
        return routerClass
      else if lib is './midi'
        return midi
      else if lib is './osc'
        return osc
      else
        return {}

    rtMidiMockGlobals =
      console: console
      exports: {},
      spyOn: spyOn

    sandbox 'spec/rtMidiMock.coffee', rtMidiMockGlobals
    rtMidiMock = rtMidiMockGlobals.exports.rtMidiMock

    utilsClass = sandbox( 'lib/utils.coffee',
      console: console
    )
    utils = utilsClass.utils

    routerClass = sandbox( 'lib/router.coffee',
      console: console
    )
    router = routerClass.router


    midiLegatoMock =
      ____: -> ->
        return true
      store: ->
        return true

    midi = sandbox 'lib/midi.coffee',
      console: console

    osc = sandbox 'lib/osc.coffee',
      console: console

    legato = sandbox 'lib/legato.coffee',
      console: console
      require: localRequire


  it 'should be able to add midi listeners.', ->
    spyOn(rtMidiMock, 'input').andCallThrough()

    wrapper = {}
    wrapper.midiInputFunction = midi.In 0

    expect(rtMidiMock.input).not.toHaveBeenCalled()
    expect(typeof(wrapper.midiInputFunction))
      .toBe('function', 'legato.legatoMidi.In should return a function to be executed by legato.')

    spyOn(wrapper, 'midiInputFunction').andCallThrough()
    spyOn(utils, 'store').andCallThrough()

    legato.in wrapper.midiInputFunction

    # It should open the correct midi port and assign a callback function to receive midi messages.
    expect(rtMidiMock.input).toHaveBeenCalled()
    expect(rtMidiMock.inputs[0].openPort).toHaveBeenCalledWith 0
    expect(rtMidiMock.inputs[0].on).toHaveBeenCalled()
    expect(utils.store).toHaveBeenCalled()
    # It should have acheived the above by calling the midiInputFunction we created with legato.midi.In
    expect(wrapper.midiInputFunction.calls.length).toBe(1)
    # The midi input function should have been passed a function to execute
    # when midi messages are received. That function will dispatch to any listeners added
    # with legato.on().
    expect(typeof(wrapper.midiInputFunction.calls[0].args[0])).toBe('function')

    wrapper.localCallback = ->
      console.log 'LOCAL CALLBACK'
    spyOn wrapper, 'localCallback'

    routeId = legato.on '/:/:/:/:', wrapper.localCallback

    expect(routeId).toBe 1, 'The route id should have been returned so the route can be removed.'
    expect(wrapper.localCallback).not.toHaveBeenCalled()

    wrapper.midiMessageRouter = rtMidiMock.inputs[0].messageCallbacks[0]
    spyOn(wrapper, 'midiMessageRouter').andCallThrough()

    # Fake a midi message.
    fakeMessage = [144, 59, 120]
    console.log 'faking a message'
    rtMidiMock.inputs[0].messageCallbacks[0] 0, fakeMessage

    # Our local callback method should be called when the route matches.
    expect(wrapper.localCallback).toHaveBeenCalled()
    expect(wrapper.localCallback.calls[0].args[0]).toBeGreaterThan 0

