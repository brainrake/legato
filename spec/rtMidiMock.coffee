'use strict'

class MidiInputMock
  inputs: ['port1', 'port2']
  messageCallbacks: []
  getPortCount: ->
    return @inputs.length
  getPortName: (index) ->
    return @inputs[index]
  openPort: (index) ->
    return true
  openVirtualPort: (index) ->
    return true
  on: (message, callback) ->
    @messageCallbacks.push(callback)
  closePort: ->
    return true

class MidiOutputMock
  outputs: ['output1', 'output2']
  messageCallbacks: []
  getPortCount: ->
    return @outputs.length
  getPortName: (index) ->
    return @outputs[index]
  openPort: ->
    return true
  openVirtualPort: ->
    return true
  on: (message, callback) ->
    @messageCallbacks.push(callback)
  closePort: ->
    return true

exports.rtMidiMock = {
  inputs:[],
  outputs:[],
  input: ->
    inputMock = new MidiInputMock()

    spyOn(inputMock, 'getPortCount').andCallThrough()
    spyOn(inputMock, 'getPortName').andCallThrough()
    spyOn(inputMock, 'openPort')
    spyOn(inputMock, 'openVirtualPort')
    spyOn(inputMock, 'on').andCallThrough()
    spyOn(inputMock, 'closePort')

    exports.rtMidiMock.inputs.push(inputMock)
    return inputMock

  output: ->
    outputMock = new MidiOutputMock()

    spyOn(outputMock, 'getPortCount').andCallThrough()
    spyOn(outputMock, 'getPortName').andCallThrough()
    spyOn(outputMock, 'openPort')
    spyOn(outputMock, 'openVirtualPort')
    spyOn(outputMock, 'on').andCallThrough()
    spyOn(outputMock, 'closePort')

    exports.rtMidiMock.outputs.push(outputMock)
    return outputMock
}