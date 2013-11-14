# Taken from Nodeunit
# https://github.com/caolan/nodeunit/blob/master/lib/utils.js
'use strict'

coffee = require 'coffee-script'
fileSys = require 'fs'
Script = require('vm').Script

# Evaluates JavaScript files in a sandbox, returning the context. The first
# argument can either be a single filename or an array of filenames. If
# multiple filenames are given their contents are concatenated before
# evalution. The second argument is an optional context to use for the sandbox.
#
# @param files
# @param {Object} sandbox
# @return {Object}
# @api public
#
exports.sandbox = (files, sandbox) ->
  if not (files instanceof Array)
    files = [files]

  source = files.map( (file) ->
    js = fileSys.readFileSync(file, 'utf8')

    if file.indexOf '.coffee', file.length - 8
      js = coffee.compile js
  ).join ''

  if not sandbox
    sandbox = {}

  script = new Script source
  result = script.runInNewContext sandbox
  return sandbox

