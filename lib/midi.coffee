'user strict'

L = utils = midi = midi_in = ___ = null

@inject = (router, legatoUtils, rtMidi) ->
  L = router
  utils = legatoUtils
  midi = rtMidi
  ___ = utils.____ '[midi]'

# Parse method copied from https://github.com/hhromic/midi-utils-js/blob/master/midiparser.js#L418
parse = (port, msg) ->
  type = msg[0] & 0xF0
  channel = msg[0] & 0x0F
  switch type
    when 0xB0
      note = msg[1] & 0x7F
      velocity = (msg[2] & 0x7F)/127.0
      ["/#{channel}/cc/#{note}", velocity]
    when 0x90
      note = msg[1] & 0x7F
      velocity = (msg[2] & 0x7F)/127.0
      ["/#{channel}/note/#{note}", velocity]
    when 0x80
      note = msg[1] & 0x7F
      ["/#{channel}/note/#{note}", 0]
    when 0xE0
      value = (msg[1] & 0x7F)/127.0
      ["/#{channel}/pitch-bend/", value]
    when 0xA0
      pressure = (msg[1] & 0x7F)/127.0
      ["/#{channel}/key-pressure/", pressure]
    when 0xC0
      number = bytes[1] & 0x7F
      ["/#{channel}/program-change/#{number}", 0 ]
    when 0xD0
      pressure = bytes[1] & 0x7F
      ["/#{channel}/channel-pressure/#{pressure}", 0]
    else
      ___ 'unknown message:', msg...


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
    # TODO Should be able to open multiple midi ports (can only open one at the moment
    # due to a defect with node-midi. Remember that we'll only need one midi instance per port.
    unless midi_in?
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
  unless midi_in?
    midi_in = new midi.input()

  for i in [0...midi_in.getPortCount()]
    midi_in.getPortName i

@outs = ->
  ___ "out: retrieving available ports."
  midi_out = new midi.output()
  for o in [0...midi_out.getPortCount()]
    midi_out.getPortName o