midi = require 'midi'

parse = (port, msg) -> 
  mtype = msg[0]/16
  return if not mtype in [0x8..0xF]
  channel = msg[0]%16+1
  switch mtype
    when 0xB
      ["/#{channel}/cc/#{msg[1]}", msg[2]/127.0]
    when 0x9  # note on
      ["/#{channel}/note/#{msg[1]}", msg[2]/127.0]
    when 0x8  # note off
      ["/#{channel}/note/#{msg[1]}" msg[2]/127.0]
    when 0xE
      ["/#{channel}/pitchbend/" msg[1]/127.0]

@in = (port) ->
  (router) ->
    input = new midi.input()
    input.openPort port
    input.on 'message', (deltaTime, msg) => 
      [path, msg] = parse(1, msg)
      router(path) msg

