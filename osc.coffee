L = require './legato'; ___ = L.____ '[osc]'
osc = require 'omgosc'

@In = (port) -> (router) ->
  ___ "In :#{port}"
  (receiver = new osc.UdpReceiver port).on '', (e) ->
    #___ "osc #{port}]", e.path, e.typetag, e.params
    router e.path, e.params[0] or e.params
  L.closet.push -> receiver.close()

@Out = (host, port, opts={}) ->
  ___ "Out #{host}:#{port}"
  sender = new osc.UdpSender host, port, opts
  (path, val) ->  # send a float
    #___ "out #{host}:#{port}", path, val 
    sender.send path, 'f', [val]
