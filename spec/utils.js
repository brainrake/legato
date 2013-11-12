/**
 * Taken from Nodeunit
 * https://github.com/caolan/nodeunit/blob/master/lib/utils.js
 */
'use strict';

// TODO Convert this class to coffee script.
var fs = require('fs'),
  Script = require('vm').Script;

/**
 * Evaluates JavaScript files in a sandbox, returning the context. The first
 * argument can either be a single filename or an array of filenames. If
 * multiple filenames are given their contents are concatenated before
 * evalution. The second argument is an optional context to use for the sandbox.
 *
 * @param files
 * @param {Object} sandbox
 * @return {Object}
 * @api public
 */
exports.sandbox = function (files, /*optional*/sandbox) {
  var source, script, result;
  if (!(files instanceof Array)) {
    files = [files];
  }

  source = files.map(function (file) {
    return fs.readFileSync(file, 'utf8');
  }).join('');

  if (!sandbox) {
    sandbox = {};
  }
  script = new Script(source);
  result = script.runInNewContext(sandbox);
  return sandbox;
};
