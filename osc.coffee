osc = require 'omgosc'

@in = (port) ->
  (router) ->
    receiver = new osc.UdpReceiver port
    receiver.on '', (e) ->
      console.log 'OSCIN', e
      router(e.path) e.params[0]

@out = (host, port) ->
  sender = new osc.UdpSender host, port
  (path, val) ->
    #console.log 'OSCOUT', arguments...
    sender.send(path, 'f', [val])  
