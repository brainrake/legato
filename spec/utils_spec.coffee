'use strict'

_ = require 'lodash'

describe 'legatoUtils', ->
  legatoUtils = {}
  mock = {}

  beforeEach ->
    legatoUtils = require( '../lib/utils' ).utils
    legatoUtils.init _

    mock =
      callback: ->
        return 1
      otherCallback: ->
        return 2

    spyOn console, 'log'

  it 'should be able to write legato logs.', ->
    legatoUtils.___()
    expect(console.log).toHaveBeenCalledWith('[legato]')

    legatoUtils.___ 'blah'
    expect(console.log).toHaveBeenCalledWith('[legato]', 'blah')

    legatoUtils.___ 'foo', 'bar', 1, true, null
    expect(console.log.calls[2].args).toEqual(['[legato]','foo','bar',1,true,null])

  it 'should allow adding of callbacks to the closet', ->
    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'The closet should start out empty.'
    legatoUtils.store mock.callback
    expect(Object.keys(legatoUtils.closet).length).toBe 1, 'The closet should have a callback in it.'

  # TODO Test generateId, remove, clear, callAll, throttle, delay and bind