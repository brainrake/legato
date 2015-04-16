'use strict'

sandbox = require('./utils').sandbox
_ = require 'lodash'
rtMidiMock = {}

describe 'legato.midi', ->
  router = {}
  midi = {}
  utils = {}

  beforeEach ->
    rtMidiMockGlobals =
      exports:{}
      console: console
      spyOn: spyOn

    sandbox('spec/rtMidiMock.coffee', rtMidiMockGlobals)
    rtMidiMock = rtMidiMockGlobals.exports.rtMidiMock

    utils = sandbox( 'lib/utils.coffee',
      console: console
    ).utils
    utils.inject _

    router = sandbox( 'lib/router.coffee',
      console: console
    ).router
    router.inject utils

    midi = sandbox 'lib/midi.coffee',
      console: console
    midi.inject router, utils, rtMidiMock

    spyOn console, 'log' # prevent logging

  it 'should be able to return the list of available midi input ports.', ->
    inputs = midi.ins()
    expect(inputs).toBeDefined()
    expect(inputs.length).toBe 2, 'It should return an array of inputs.'
    expect(inputs[0]).toBe 'port1', 'It should have returned the correct port name.'

  it 'should be able to return the list of available midi output ports.', ->
    outputs = midi.outs()
    expect(outputs).toBeDefined()
    expect(outputs.length).toBe 2, 'It should return an array of output ports.'
    expect(outputs[0]).toBe 'output1', 'It should have returned the correct port name.'

  it 'should be able to create a new midi input object.', ->
    inputFunction = midi.In 'port1'
    expect(inputFunction).toBeDefined()
    expect(typeof inputFunction).toBe 'function', 'The router returned should be a function.'

    router = {}
    inputFunction router

    expect(rtMidiMock.inputs.length).toBe 1, 'It should have created a new midi input object.'
    expect(rtMidiMock.inputs[0].openPort).toHaveBeenCalled()
    expect(rtMidiMock.inputs[0].openVirtualPort).not.toHaveBeenCalled()
    expect(rtMidiMock.inputs[0].on).toHaveBeenCalled()

  # TODO Allow opening more than one midi port. This is currently disabled due to a bug with node-midi.
  xit 'should be able to create multiple inputs listening on the same port.', ->
    input1 = midi.In('port1')
    router1 = {}
    input1(router1)

    input2 = midi.In('port2', true)
    router2 = {}
    input2(router2)

    expect(rtMidiMock.inputs.length).toBe(2, 'Two separate inputs should have been created.')
    expect(rtMidiMock.inputs[1].openPort).not.toHaveBeenCalled()
    expect(rtMidiMock.inputs[1].openVirtualPort).toHaveBeenCalled()

  it 'should close its input port when legato is closed.', ->
    router.in '/myPort', midi.In('port1')

    expect(rtMidiMock.inputs[0].closePort).not.toHaveBeenCalled()

    router.init()

    expect(rtMidiMock.inputs[0].closePort).toHaveBeenCalled()

  it 'should be able to create new midi outputs.', ->
    id1 = midi.Out 'output1'

    expect(rtMidiMock.outputs.length).toBe 1, 'It should have created a midi output object.'
    expect(rtMidiMock.outputs[0].openPort).toHaveBeenCalled()
    expect(rtMidiMock.outputs[0].on).toHaveBeenCalled()
    expect(Object.keys(utils.closet).length).toBe 1, 'It should have added a close port callback to legato.'

    id2 = midi.Out 'output1', true

    expect(rtMidiMock.outputs.length).toBe 2, 'It should have created a second output object.'
    expect(rtMidiMock.outputs[1].openPort).not.toHaveBeenCalled()
    expect(rtMidiMock.outputs[1].openVirtualPort).toHaveBeenCalled()
    expect(id1).not.toEqual id2, 'The two ouput ids should be unique.'

  it 'should correctly parse midi messages.', ->
    mock = {
      mockCallback: (path, value) -> console.log path, value
    }
    spyOn mock, 'mockCallback'

    midiRegister = midi.In('port1')
    midiRegister( mock.mockCallback )

    rtMidiMock.inputs[0].messageCallbacks[0](0, [153, 44, 103])

    expect(mock.mockCallback).toHaveBeenCalledWith '/9/note/44', 103/127

    rtMidiMock.inputs[0].messageCallbacks[0](0, [144, 62, 120])

    expect(mock.mockCallback.calls.length).toBe 2
    expect(mock.mockCallback.calls[1].args).toEqual ['/0/note/62', 120/127]

