'use strict'

sandbox = require('./utils').sandbox
rtMidiMock = {}

describe 'legato.midi', ->
  legato = {}
  legatoMidi = {}

  requireMock = (libName) ->
    if(libName == 'midi')
      return rtMidiMock
    if(libName == './legato')
      return legato
    else
      return {}

  beforeEach ->
    rtMidiMockGlobals =
      exports:{}
      spyOn: spyOn

    sandbox('spec/rtMidiMock.coffee', rtMidiMockGlobals)
    rtMidiMock = rtMidiMockGlobals.exports.rtMidiMock

    legatoDependencies =
      console: console
      require: requireMock

    legato = sandbox 'lib/legato.coffee', legatoDependencies
    legatoMidi = sandbox 'lib/midi.coffee', legatoDependencies

    spyOn console, 'log' # prevent logging

#  it 'should be able to return the list of available midi input ports.', ->
#    inputs = legatoMidi.ins()
#    expect(inputs).toBeDefined()
#    expect(inputs.length).toBe 2, 'It should return an array of inputs.'
#    expect(inputs[0]).toBe 'port1', 'It should have returned the correct port name.'
#
#  it 'should be able to return the list of available midi output ports.', ->
#    outputs = legatoMidi.outs()
#    expect(outputs).toBeDefined()
#    expect(outputs.length).toBe 2, 'It should return an array of output ports.'
#    expect(outputs[0]).toBe 'output1', 'It should have returned the correct port name.'
#
#  it 'should be able to create a new midi input objects.', ->
#    inputFunction = legatoMidi.In 'port1'
#    expect(inputFunction).toBeDefined()
#    expect(typeof inputFunction).toBe 'function', 'The router returned should be a function.'
#
#    router = {}
#    inputFunction router
#
#    expect(rtMidiMock.inputs.length).toBe 1, 'It should have created a new midi input object.'
#    expect(rtMidiMock.inputs[0].openPort).toHaveBeenCalled()
#    expect(rtMidiMock.inputs[0].openVirtualPort).not.toHaveBeenCalled()
#    expect(rtMidiMock.inputs[0].on).toHaveBeenCalled()
#    expect(legato.closet.length)
#      .toBe 1, 'The legato closet should have been updated with a function to close this port.'
#
#  it 'should be able to create multiple inputs listening on the same port.', ->
#    input1 = legatoMidi.In('port1')
#    router1 = {}
#    input1(router1)
#
#    input2 = legatoMidi.In('port2', true)
#    router2 = {}
#    input2(router2)
#
#    expect(rtMidiMock.inputs.length).toBe(2, 'Two separate inputs should have been created.')
#    expect(rtMidiMock.inputs[1].openPort).not.toHaveBeenCalled()
#    expect(rtMidiMock.inputs[1].openVirtualPort).toHaveBeenCalled()
#
#  it 'should close its input port when legato is closed.', ->
#    router = {}
#    legatoMidi.In('port1')(router)
#
#    expect(rtMidiMock.inputs[0].closePort).not.toHaveBeenCalled()
#
#    legato.init()
#
#    expect(rtMidiMock.inputs[0].closePort).toHaveBeenCalled()
#
#  it 'should be able to create new midi outputs.', ->
#    legatoMidi.Out 'output1'
#
#    expect(rtMidiMock.outputs.length).toBe 1, 'It should have created a midi output object.'
#    expect(rtMidiMock.outputs[0].openPort).toHaveBeenCalled()
#    expect(rtMidiMock.outputs[0].on).toHaveBeenCalled()
#    expect(legato.closet.length).toBe 1, 'It should have added a close port callback to legato.'
#
#    legatoMidi.Out 'output1', true
#
#    expect(rtMidiMock.outputs.length).toBe 2, 'It should have created a second output object.'
#    expect(rtMidiMock.outputs[1].openPort).not.toHaveBeenCalled()
#    expect(rtMidiMock.outputs[1].openVirtualPort).toHaveBeenCalled()
#
#  it 'should close its output port when legato is closed.', ->
#    legatoMidi.Out 'output1'
#
#    expect(rtMidiMock.outputs[0].closePort).not.toHaveBeenCalled()
#
#    legato.init()
#
#    expect(rtMidiMock.outputs[0].closePort).toHaveBeenCalled()