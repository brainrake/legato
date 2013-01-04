___ = require('./legato').___
osc = require 'omgosc'

@in = (port) ->
  ___ '[in]', 'osc port=#{port}'
  (router) ->
    receiver = new osc.UdpReceiver port
    receiver.on '', (e) ->
      ___ '[osc.in]', e
      router(e.path) e.params[0]

@out = (host, port) ->
  ___ '[out]', 'osc host='+host+' port='+port
  sender = new osc.UdpSender host, port
  (path, val) ->
    ___ '[osc.out]', arguments...
    sender.send(path, 'f', [val])
