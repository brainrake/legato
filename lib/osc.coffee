'use strict'

utils = osc = ___ = null

@inject = (legatoUtils, omgosc) ->
  utils = legatoUtils
  osc = omgosc
  ___ = utils.____ '[osc]'

@In = (port) ->
  (router) ->
    ___ "in: #{port}"
    (receiver = new osc.UdpReceiver port).on '', (e) ->
      #___ "osc #{port}]", e.path, e.typetag, e.params
      router e.path, (if e.params[0]? then e.params[0] else e.params)
    return -> receiver.close(); ___ 'in: close'

@Out = (host, port, opts={}) ->
  ___ "out #{host}:#{port}"
  sender = new osc.UdpSender host, port, opts
  # can we store a shutdown function for this output and return the id in the closet and
  # return the function to send a message.
  (path, val) ->  # send a float
    #___ "out #{host}:#{port}", path, val
    sender.send path, 'f', [val]
