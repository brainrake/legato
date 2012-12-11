legato - OSC patch bay
======================

Interfaces
----------

* OSC via `omgosc`
* MIDI via `node-midi` via `rtmidi` (cross-platform)
* volume control via `amixer`


Usage
-----

    L = require('./legato')

    L.in '/midi/1': L.midi.in 1
    L.in '/oscin': L.osc.in 7777

    oscout = L.osc.out '10.0.0.130', 7777

    L.throttle 50, i... for i in [
      ['/midi/1/:/cc/12', -> L.amixer @val]
      ['/oscin/1/fader:', -> L.amixer @val]
    ]

    L.on '/midi/1/:/cc/12', ->
      oscout '/1/fader1', @val

    L.on '/midi/1/:/note/:', ->
      console.log @path, @val
