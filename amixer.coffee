_ = require 'lodash'
spawn = require('child_process').spawn
amixer = spawn 'amixer', ['-q', '-s']

@amixer = (val) =>
  return if val*1 is NaN or not 0 < val < 1
  cmd = "sset PCM #{Math.floor(val*100)}%\n"
  #console.log cmd
  amixer.stdin.write(cmd);
