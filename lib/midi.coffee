L = require './legato'; ___ = L.____ '[midi]'
midi = require 'midi'

parse = (port, msg) ->
  channel = msg[0] % 16 + 1
  switch msg[0] / 16  # message type
    when 0xB
      ["/#{channel}/cc/#{msg[1]}", msg[2]/127.0]
    when 0x9  # note on
      ["/#{channel}/note/#{msg[1]}", msg[2]/127.0]
    when 0x8  # note off
      ["/#{channel}/note/#{msg[1]}", 0]
    when 0xE
      ["/#{channel}/pitchbend/", msg[1]/127.0]
    else
      ___ undefined, 'message:', msg...
      

@In = (port, virtual=no) -> (router) ->
  ___ "in#{port}#{virtual and 'v' or ''} open"
  midi_in = new midi.input()
  midi_in["open#{virtual and 'Virtual' or ''}Port"] port
  midi_in.on 'message', (deltaTime, msg) ->
    router parse(port, msg)...
  L.closet.push ->  midi_in.closePort(); ___ 'in.close'

@Out = (port, virtual=no) ->
  ___ "[midi.out#{port}#{virtual and 'v' or ''}] open"
  midi_out = new midi.output()
  midi_out["open#{virtual and 'Virtual' or ''}Port"] port
  midi_out.on 'message', (deltaTime, msg) ->
    router parse(port, msg)...
  L.closet.push -> midi_out.closePort(); ___ 'out.close'

@ins = ->
  midi_in = new midi.input()
  for i in [0...midi_in.getPortCount()]
    midi_in.getPortName i

@outs = ->
  midi_out = new midi.output()
  for o in [0...midi_out.getPortCount()]
    midi_out.getPortName o