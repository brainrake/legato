___ = require('./legato').___
osc = require 'omgosc'

@in = (port) -> (router) ->
  ___ "[osc.in+] :#{port}"
  receiver = new osc.UdpReceiver port
  receiver.on '', (e) ->
    #___ "[osc.in:#{port}]", e.path, e.typetag, e.params
    router e.path, switch e.params.length
      when 0 then null
      when 1 then e.params[0]
      else e.params
  close: -> receiver.close()

@out = (host, port, opts={}) ->
  ___ "[osc.out] open #{host}:#{port}"
  sender = new osc.UdpSender host, port, opts
  (path, val) ->
    ___ "[osc.out] #{host}:#{port}", path, val 
    sender.send path, 'f', [val]
