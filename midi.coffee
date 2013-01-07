midi = require 'midi'
___ = require('./legato').___


parse = (port, msg) -> 
  mtype = msg[0]/16
  channel = msg[0]%16+1
  switch mtype
    when 0xB
      ["/#{channel}/cc/#{msg[1]}", msg[2]/127.0]
    when 0x9   # note on
      ["/#{channel}/note/#{msg[1]}", msg[2]/127.0]
    when 0x8   # note off
      ["/#{channel}/note/#{msg[1]}", 0]
    when 0xE
      ["/#{channel}/pitchbend/", msg[1]/127.0]
    else ___ '[midi.in] unknown message:', msg...; undefined


@in = (port, virtual=off) -> (router) ->
  ___ "[midi.in#{port}] open"
  midi_in = new midi.input()
  if virtual then midi_in.openVirtualPort 'legato'
  else midi_in.openPort port
  midi_in.on 'message', (deltaTime, msg) => 
    router parse(port, msg)...
  close: -> midi_in.closePort()

@ins = ->
  midi_in = new midi.input()
  for i in [0...midi_in.getPortCount()]
    midi_in.getPortName(i)

@out = (port, virtual=off) ->
  ___ "[midi.in#{port}] open"
  midi_in = new midi.input()
  if virtual then midi_out.openVirtualPort 'legato'
  else midi_out.openPort port
  midi_in.on 'message', (deltaTime, msg) => 
    router parse(port, msg)...
  close: midi_in.closePort

@outs = ->
  midi_out = new midi.output()
  for o in [0...midi_out.getPortCount()]
    midi_out.getPortName(o)