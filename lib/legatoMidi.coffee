'user strict'

L = utils = midi = ___ = null

@init = (router, legatoUtils, rtMidi) ->
  L = router
  utils = legatoUtils
  midi = rtMidi
  ___ = utils.____ '[midi]'

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
#     @param router {Function} The callback that will be called when new messages are received. This
#         function is created by legato and will check all registered routes for matching paths.
#     @return {Function} A function that should be called to close down this listener.
@In = (port, virtual=no) ->
  (router) ->
    ___ "in: #{port}#{virtual and 'v' or ''} open"
    midi_in = new midi.input()
    # TODO Should we guard against opening virtual ports on systems that don't provide them?
    midi_in["open#{virtual and 'Virtual' or ''}Port"] port
    midi_in.on 'message', (deltaTime, msg) ->
      router parse(port, msg)...
    return -> midi_in.closePort(); ___ 'in:˘close'

@Out = (port, virtual=no) ->
  ___ "out: #{port}#{virtual and 'v' or ''} open"
  midi_out = new midi.output()
  midi_out["open#{virtual and 'Virtual' or ''}Port"] port
  # can we store a shutdown function for this output and return the id in the closet and
  # return the function to send a message.
  # and why does this call the midi_out.on function?
  midi_out.on 'message', (deltaTime, msg) ->
    router parse(port, msg)...
  return utils.store -> midi_out.closePort(); ___ 'out: close'

@ins = ->
  ___ "in: retrieving available ports."
  midi_in = new midi.input()
  for i in [0...midi_in.getPortCount()]
    midi_in.getPortName i

@outs = ->
  ___ "out: retrieving available ports."
  midi_out = new midi.output()
  for o in [0...midi_out.getPortCount()]
    midi_out.getPortName o