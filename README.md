legato - OSC patch bay
======================

Interfaces
----------

* OSC via `omgosc`
* MIDI via `node-midi` via `rtmidi` (cross-platform)
* volume control via `amixer`


Example Usage
-------------

    L = require('./legato')

    # inputs
    L.in '/midi/1', L.midi.in 1
    L.in '/oscin', L.osc.in 7777

    # outputs
    volout = L.amixer 1, 'Master'
    oscout = L.osc.out '192.168.1.13', 7777

    # handlers
    vol = L.throttle 50, ->
      volout @val
      oscout '/1/fader1', @val

    lofasz = -> exec 'mplayer /opt/lofasz.wav' if @val


    # mapping

    L.on '/midi/1/:/cc/12', vol
    L.on '/oscin/:/fader:', vol

    L.on p, lofasz for p in [
     '/oscin/2/push1'
     '/midi/1/:/note/70'
    ]

    #L.on '/midi/1/:/note/:', -> console.log @path, @val


