'user strict'

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


# Returns a function that can be called to start listening on a midi port.
# @param port {int} The index of the port to open.
# @param virtual {boolean} Whether we are opening a virtual port. Virtual is used if you wish to
# open a new port as opposed to connecting to an existing port.
# @return {Function} A function that can be called to start listening on this port.
#     The returned function takes the following parameters.
#     @param id {int} The id of the input. This will be used to store the shut down method.
#     @param router {Function} The callback that will be called when new messages are received. This
#         function is created by legato and will check all registered routes for matching paths.
@In = (port, virtual=no) ->
  (id, router) ->
    ___ "in:#{port}#{virtual and 'v' or ''} open"
    midi_in = new midi.input()
    # TODO Should we guard against opening virtual ports on systems that don't provide them?
    midi_in["open#{virtual and 'Virtual' or ''}Port"] port
    midi_in.on 'message', (deltaTime, msg) ->
      router parse(port, msg)...
    # TODO Could we remove the dependency on L by returning the callback and letting legato
    # store it in the closet?
    L.store id, ->  midi_in.closePort(); ___ 'in.close'

@Out = (port, virtual=no) ->
  ___ "[midi.out#{port}#{virtual and 'v' or ''}] open"
  midi_out = new midi.output()
  midi_out["open#{virtual and 'Virtual' or ''}Port"] port
  midi_out.on 'message', (deltaTime, msg) ->
    router parse(port, msg)...
  L.store -> midi_out.closePort(); ___ 'out.close'

@ins = ->
  midi_in = new midi.input()
  for i in [0...midi_in.getPortCount()]
    midi_in.getPortName i

@outs = ->
  midi_out = new midi.output()
  for o in [0...midi_out.getPortCount()]
    midi_out.getPortName o