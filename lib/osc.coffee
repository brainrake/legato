L = require './legato'; ___ = L.____ '[osc]'
osc = require 'omgosc'

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
  (path, val) ->
    #___ "out #{host}:#{port}", path, val
    sender.send path, val.types, val.values
