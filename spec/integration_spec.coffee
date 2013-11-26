'use strict'

# TODO Integrate with Travis?
# TODO Add support for ddescribe and iit to jasmine-node?

sandbox = require('./utils').sandbox
_ = require 'lodash'

rtMidiMock = {}
legato = {}
midi = {}
midiLegatoMock = {}

describe 'integration', ->

  beforeEach ->
    rtMidiMockGlobals =
      console: console
      exports: {},
      spyOn: spyOn

    sandbox 'spec/rtMidiMock.coffee', rtMidiMockGlobals
    rtMidiMock = rtMidiMockGlobals.exports.rtMidiMock

    midiLegatoMock =
      ____: -> ->
        return true
      store: ->
        return true

    # TODO Can we place the mock require method outside of the beforeEach?
    legatoMidiGlobals =
      console: console
      require: (lib) ->
        if lib is 'lodash'
          return _
        else if lib is 'midi'
          return rtMidiMock
        else if lib is './legato'
          return midiLegatoMock
        else
          return {}

    midi = sandbox 'lib/midi.coffee', legatoMidiGlobals

    legatoGlobals =
      console: console
      require: (lib) ->
        if lib is 'lodash'
          return _
        else if lib is 'midi'
          return rtMidiMock
        else if lib is './midi'
          return midi
        else
          return {}

    legato = sandbox 'lib/legato.coffee', legatoGlobals

  it 'should be able to add midi listeners.', ->
    spyOn(rtMidiMock, 'input').andCallThrough()

    wrapper = {}
    wrapper.midiInputFunction = legato.midi.In 0

    expect(rtMidiMock.input).not.toHaveBeenCalled()
    expect(typeof(wrapper.midiInputFunction))
      .toBe('function', 'legato.midi.In should return a function to be executed by legato.')

    spyOn(wrapper, 'midiInputFunction').andCallThrough()
    spyOn(midiLegatoMock, 'store').andCallThrough()

    legato.in '/prefix', wrapper.midiInputFunction

    # It should open the correct midi port and assign a callback function to receive midi messages.
    expect(rtMidiMock.input).toHaveBeenCalled()
    expect(rtMidiMock.inputs[0].openPort).toHaveBeenCalledWith 0
    expect(rtMidiMock.inputs[0].on).toHaveBeenCalled()
    # Since we had to mock out the circular dependency in legato.mock, our midiLegatoMock will
    # will be asked to store the shutdown callback.
    expect(midiLegatoMock.store).toHaveBeenCalled()
    # It should have acheived the above by calling the midiInputFunction we created with legato.midi.In
    expect(wrapper.midiInputFunction.calls.length).toBe(1)
    # The midi input function should have been passed a function to execute
    # when midi messages are received. That function will dispatch to any listeners added
    # with legato.on().
    expect(typeof(wrapper.midiInputFunction.calls[0].args[1])).toBe('function')

#    wrapper.localCallback = ->
#    spyOn wrapper, 'localCallback'
#
#    routeId = legato.on '/:/:/:/:', wrapper.localCallback
#
#    expect(routeId).toBe 1, 'The route id should have been returned so the route can be removed.'
#    expect(wrapper.localCallback).not.toHaveBeenCalled()
#
#    wrapper.midiMessageRouter = rtMidiMock.inputs[0].messageCallbacks[0]
#    spyOn(wrapper, 'midiMessageRouter').andCallThrough()
#
#    # Fake a midi message.
#    fakeMessage = [144, 59, 120]
#    rtMidiMock.inputs[0].messageCallbacks[0] 0, fakeMessage
#
#    # Our local callback method should be called when the route matches.
#    expect(wrapper.localCallback).toHaveBeenCalled()
#    expect(wrapper.localCallback.calls[0].args[0]).toBeGreaterThan 0


