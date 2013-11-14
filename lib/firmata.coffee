L = require './legato'; ___ = L.____ '[firmata]'
_ = require 'lodash'; Deferred = (require 'underscore.deferred').Deferred

Serial = (port, baud=9600, opts={}) ->
  new ((require 'serialport').SerialPort) port, _.extend opts, baudrate: baud, buffersize:1
  
@Board = (port= '/dev/ttyACM0', baud, opts) -> o=
  loading: (new Deferred())
  board: (new (require 'firmata').Board (Serial port, baud, opts), (err) ->
    o.loading.resolve(); ___ "open", if err then err else ''
    L.closet.push -> o.board.sp.close() ;___ 'close' )
  Out: (pin, mode, cb) ->
    o.loading.done ->
      ___ 'Out', pin, mode
      o.board.pinMode pin, o.board.MODES[mode]
    (v) -> if o.board.pins then (cb v) else ___ 'not loaded yet'
  Pwm: (pin) ->
    o.Out pin, 'PWM', (v) ->
      o.board.analogWrite pin, v*255
  Dout: (pin) ->
    o.Out pin, 'OUTPUT', (v) ->
      o.board.digitalWrite pin, v > 0
  Servo: (pin) ->
    o.Out pin, 'SERVO', (v) ->
      o.board.servoWrite pin, v*255
