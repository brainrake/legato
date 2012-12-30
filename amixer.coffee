_ = require 'lodash'
___ = require('./legato').___
spawn = require('child_process').spawn

@amixer = (card=0, control='PCM') ->
  amixer = spawn 'amixer', ['-q', '-s', '-c', card]
  (val) ->
      return if val*1 is NaN or not 0 <= val <= 1
      cmd = "sset #{control} #{Math.floor(val*100)}%"
      ___ '[amixer]', cmd
      amixer.stdin.write(cmd+'\n');

