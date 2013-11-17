'use strict'

sandbox = require('./utils').sandbox

describe 'legato.midi', ->
  legato = {}
  legatoMidi = {}

  class MidiInputMock
    inputs: ['port1', 'port2']
    getPortCount: ->
      return @inputs.length
    getPortName: (index) ->
      return @inputs[index]
    openPort: (index) ->
      return true
    openVirtualPort: (index) ->
      return true
    on: (message, callback) ->
      return true
    closePort: ->
      return true

  class MidiOutputMock
    outputs: ['output1', 'output2']
    getPortCount: ->
      return @outputs.length
    getPortName: (index) ->
      return @outputs[index]
    openPort: ->
      return true
    openVirtualPort: ->
      return true
    on: (message, callback) ->
      return true
    closePort: ->
      return true

  midiMock = {}
  midiMock.input = ->
    inputMock = new MidiInputMock()

    spyOn(inputMock, 'getPortCount').andCallThrough()
    spyOn(inputMock, 'getPortName').andCallThrough()
    spyOn(inputMock, 'openPort')
    spyOn(inputMock, 'openVirtualPort')
    spyOn(inputMock, 'on')
    spyOn(inputMock, 'closePort')

    midiMock.inputs.push(inputMock)
    return inputMock
  midiMock.output = ->
    outputMock = new MidiOutputMock()

    spyOn(outputMock, 'getPortCount').andCallThrough()
    spyOn(outputMock, 'getPortName').andCallThrough()
    spyOn(outputMock, 'openPort')
    spyOn(outputMock, 'openVirtualPort')
    spyOn(outputMock, 'on')
    spyOn(outputMock, 'closePort')

    midiMock.outputs.push(outputMock)
    return outputMock

  beforeEach ->
    midiMock.inputs = []
    midiMock.outputs = []

    legatoDependencies =
      console: console
      require: require

    legato = sandbox 'lib/legato.coffee', legatoDependencies

    legatoMidiDependencies =
      console: console
      require: (libName) ->
        if(libName == 'midi')
          return midiMock
        if(libName == './legato')
          return legato
        else
          return require(libName)

    legatoMidi = sandbox 'lib/midi.coffee', legatoMidiDependencies

    spyOn console, 'log' # prevent logging

  it 'should be able to return the list of available midi input ports.', ->
    inputs = legatoMidi.ins()
    expect(inputs).toBeDefined()
    expect(inputs.length).toBe 2, 'It should return an array of inputs.'
    expect(inputs[0]).toBe 'port1', 'It should have returned the correct port name.'

  it 'should be able to return the list of availabel midi output ports.', ->
    outputs = legatoMidi.outs()
    expect(outputs).toBeDefined()
    expect(outputs.length).toBe 2, 'It should return an array of output ports.'
    expect(outputs[0]).toBe 'output1', 'It should have returned the correct port name.'

  it 'should be able to create a new midi input objects.', ->
    inputFunction = legatoMidi.In 'port1'
    expect(inputFunction).toBeDefined()
    expect(typeof inputFunction).toBe 'function', 'The router returned should be a function.'

    router = {}
    inputFunction router

    expect(midiMock.inputs.length).toBe 1, 'It should have created a new midi input object.'
    expect(midiMock.inputs[0].openPort).toHaveBeenCalled()
    expect(midiMock.inputs[0].openVirtualPort).not.toHaveBeenCalled()
    expect(midiMock.inputs[0].on).toHaveBeenCalled()
    expect(legato.closet.length)
      .toBe 1, 'The legato closet should have been updated with a function to close this port.'

  it 'should be able to create multiple inputs listening on the same port.', ->
    input1 = legatoMidi.In('port1')
    router1 = {}
    input1(router1)

    input2 = legatoMidi.In('port2', true)
    router2 = {}
    input2(router2)

    expect(midiMock.inputs.length).toBe(2, 'Two separate inputs should have been created.')
    expect(midiMock.inputs[1].openPort).not.toHaveBeenCalled()
    expect(midiMock.inputs[1].openVirtualPort).toHaveBeenCalled()

  it 'should close its input port when legato is closed.', ->
    router = {}
    legatoMidi.In('port1')(router)

    expect(midiMock.inputs[0].closePort).not.toHaveBeenCalled()

    legato.init()

    expect(midiMock.inputs[0].closePort).toHaveBeenCalled()

  it 'should be able to create new midi outputs.', ->
    legatoMidi.Out 'output1'

    expect(midiMock.outputs.length).toBe 1, 'It should have created a midi output object.'
    expect(midiMock.outputs[0].openPort).toHaveBeenCalled()
    expect(midiMock.outputs[0].on).toHaveBeenCalled()
    expect(legato.closet.length).toBe 1, 'It should have added a close port callback to legato.'

    legatoMidi.Out 'output1', true

    expect(midiMock.outputs.length).toBe 2, 'It should have created a second output object.'
    expect(midiMock.outputs[1].openPort).not.toHaveBeenCalled()
    expect(midiMock.outputs[1].openVirtualPort).toHaveBeenCalled()

  it 'should close its output port when legato is closed.', ->
    legatoMidi.Out 'output1'

    expect(midiMock.outputs[0].closePort).not.toHaveBeenCalled()

    legato.init()

    expect(midiMock.outputs[0].closePort).toHaveBeenCalled()