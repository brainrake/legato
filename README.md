Why?
----

We live in a networked world. Although communication technology is built into most of our devices, it's still hard to get them to talk to eachother.

This is unacceptable.

Wether you want to control a live music performance using a MIDI controller and a rake or whatnot, or just turn on the coffee machine with a joystick, it should be easy.

How?
----

Different types of devices have different interfaces. For musical instrument controllers and digital audio software, there's [MIDI](http://en.wikipedia.org/wiki/Midi), and maybe [OSC](http://en.wikipedia.org/wiki/Open_Sound_Control). For lighting, there's [DMX](http://en.wikipedia.org/wiki/DMX512). But what if you want to control your music software with a gamepad or Wii Remote or your tablet's touchscreen? Or have some LEDs blink to the tempo? Or open the garage door with your phone?

Maybe you've done a little research and tried the proprietary, paid, OSX-only [OSCulator](http://www.osculator.net/) that constrains you to a GUI where each mapping has to be added manually, or the unmaintained [GlovePIE](http://glovepie.org/glovepie.php) on Windows. Unsatisfactory. Maybe you've tried patching things together with graphical programming tools like [Pure Data](http://puredata.info/) or [Max/MSP](http://cycling74.com/products/max/), but gave up after a few controls because there were too many boxes on the screen, and it couldn't be easily modified anyway. Or it dit sort of work, but you keep wishing there was an easier way.

The solution is a unified interface to communicate with devices and software, and a simple way to route messages between them.

Naturally, it should work across devices and networks.


What?
-----

`legato` is a small `node.js` library written in coffeescript, but that doesn't really matter. `legato` is designed to let you create beautifully simple connections between devices and software, regardless of environment.

There is built-in support for OSC, MIDI, and some other stuff. It's easily extensible.

To use it, just write a (really) small program that maps inputs to outputs.


### Usage

[node.js](http://nodejs.org/) is required. `legato` can be installed using `npm`. It is suggested that the `coffee` binary be installed globally with `npm install -g coffee-script`.

Create a directory for your project and install legato as a dependency:

    $ mkdir control
    $ cd control
    $ npm install legato

Create and edit a mapping file, e.g. `mapping.coffee`. You can also use JS if you really want to.
Here's an example:

    L = require('legato').init()

    L.in '/midi1', L.midi.in 1  

    oscout = L.osc.out '192.168.1.255', 7778, broadcast: on 

    L.on '/midi1/1/cc/1', ->             # listen for MIDI CC 1 on channel 1
      console.log 'CC1', @val            # log the value

    L.on '/midi1/:/note/:', ->           # listen for all MIDI notes on any channel
      oscout @path, @val                 # forward them to OSC

    L.on '', -> console.log @path, @val  # log all events

`legato` is livecoding-friendly. Run your instance with coffeescript's 'watch' mode and watch it reload when you save the file.

    $ coffee -w mapping.coffee
