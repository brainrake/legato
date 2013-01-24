___ = (require './legato').___
spawn = (require 'child_process').spawn

@Out = (card=0, control='PCM') ->
  proc = spawn 'amixer', ['-q', '-s', '-c', card]
  (val) -> if val*1 isnt NaN and 0 <= val <= 1
    cmd = "sset #{control} #{Math.floor(val*100)}%"
    proc.stdin.write cmd+'\n'
    ___ '[amixer]', cmd
