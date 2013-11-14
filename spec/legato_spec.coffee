'use strict'

sandbox = require('./utils').sandbox
_ = require 'lodash'

describe 'legato', ->
  legato = {}
  mock = {}

  beforeEach ->
    boxGlobals =
      console: console
      require: require

    legato = sandbox 'lib/legato.coffee', boxGlobals

  beforeEach ->
    mock =
      callback: ->
        console.log('mock.callback')
        return 1
      otherCallback: ->
        console.log('mock.otherCallback')
        return 2

  it 'should be able to write legato logs.', ->
    spyOn(console, 'log')

    legato.___()
    expect(console.log).toHaveBeenCalledWith('[legato]')

    legato.___('blah')
    expect(console.log).toHaveBeenCalledWith('[legato]', 'blah')

    legato.___('foo', 'bar', 1, true, null)
    expect(console.log.calls[2].args).toEqual(['[legato]','foo','bar',1,true,null])

  it 'should allow adding of callbacks to the closet', ->
    expect(legato.closet.length).toBe(0, 'The closet should start out empty.')
    legato.store(mock.callback)
    expect(legato.closet.length).toBe(1, 'The closet should have a callback in it.')

  it 'should call all of the closeted callbacks on deinit', ->
    spyOn(mock, 'callback')
    spyOn(mock, 'otherCallback')

    expect(legato.closet.length).toBe(0, 'The closet should start out empty.')
    expect(legato.routes.length).toBe(0, 'The routes should be cleared.')

    legato.store(mock.callback)
    legato.store(mock.otherCallback)
    expect(legato.closet.length).toBe(2, 'The closet should have our callback.')

    legato.deinit()
    expect(mock.callback).toHaveBeenCalled()
    expect(mock.otherCallback).toHaveBeenCalled()
    expect(legato.closet.length).toBe(0, 'The closet should have been cleared.')
    expect(legato.routes.length).toBe(0, 'The routes should be cleared.')

  it 'should be possible to reinitialize legato', ->
    spyOn(console, 'log') # prevent logs
    spyOn(mock, 'callback')
    spyOn(mock, 'otherCallback')

    expect(legato.closet.length).toBe(0, 'The closet should start empty.')
    expect(legato.routes.length).toBe(0, 'The routes should be cleared.')

    legato.store(mock.callback)
    legato.store(mock.otherCallback)
    returned = legato.init()

    expect(mock.callback).toHaveBeenCalled()
    expect(mock.otherCallback).toHaveBeenCalled()
    expect(legato.closet.length).toBe(0, 'The closet should have been emptied.')
    expect(returned).toBe(legato, 'The legato object should be returned from init.')
    expect(legato.routes.length).toBe(0, 'The routes should be cleared.')

  it 'should provide access to the _.throttle method', ->
    spyOn(_, 'throttle')
    expect(_.throttle).not.toHaveBeenCalled()

    legato.throttle(100, mock.callback)
    expect(_.throttle).toHaveBeenCalledWith(mock.callback, 100)

  it 'should provide access to the _.delay method.', ->
    spyOn(_, 'delay')
    expect(_.delay).not.toHaveBeenCalled()

    legato.delay(100, mock.callback)
    expect(_.delay).toHaveBeenCalledWith(mock.callback, 100)

  it 'should be able to add new routes.', ->
    spyOn(console, 'log')

    expect(legato.routes.length).toBe(0, 'It should start without any routes.')

    legato.on('/input1/1/note/1', mock.callback)

    expect(console.log).toHaveBeenCalled()
    expect(legato.routes.length).toBe(1, 'It should have added a new route.')

    legato.on('/input1/2/note/2', mock.otherCallback)

    expect(console.log.calls.length).toBe(2, 'It should have sent two log messages.')
    expect(legato.routes.length).toBe(2, 'It should have added another route.')

  it 'should be able to create strict routes.', ->
    spyOn(console, 'log') # prevent logs
    legato.on('/input1/1/note/1', mock.callback)

    route = legato.routes[0][0]

    expect(('/input1/1/note/1').match(legato.routes[0][0]).length)
      .toBe(1, 'The path stored should match our route exactly.')
    expect(('/input1/1/note/12').match(route))
      .toBeNull('The path should not match if the notes are different.')
    expect(('/input2/1/note/1').match(route))
      .toBeNull('The path should not match if the input is different.')
    expect(('/input1/2/note/1').match(route))
      .toBeNull('The path should not match if the channels are different.')
    expect(('/input1/1/cc/1').match(route))
      .toBeNull('The path should not match if the note type is different.')

  it 'should be able to create routes to match any channel', ->
    spyOn(console, 'log') # prevent logs
    legato.on('/input1/:/note/1', mock.callback)

    route = legato.routes[0][0]

    expect(('/input1/1/note/1').match(route).length)
      .toBeGreaterThan(1, 'Events on channel one should match.')
    expect(('/input1/16/note/1').match(route).length)
      .toBeGreaterThan(1, 'Events on any channel should match.')
    expect(('/input2/1/note/1').match(route))
      .toBeNull('Events on different inputs should not match.')
    expect(('/input1/1/cc/1').match(route))
      .toBeNull('Events with different types should not match.')

  it 'should be able to create routes to match anything.', ->
    spyOn(console, 'log') # prevent logs
    legato.on('/:/:/:/:', mock.callback)

    route = legato.routes[0][0]

    expect(('/input3/2/cc/7').match(route)).not.toBeNull('Any input event should match.')
    expect(('/input1/1/note/1').match(route)).not.toBeNull('Any input event should match.')

  it 'should dispatch to the correct paths.', ->
    spyOn(console, 'log') # prevent logs
    spyOn(mock, 'callback')
    spyOn(mock, 'otherCallback')

    legato.on('/input1/1/note/1', mock.callback)
    legato.on('/input1/:/note/1', mock.callback)
    legato.on('/input1/:/note/2', mock.otherCallback)
    legato.on('/:/:/:/:', mock.callback)
    legato.on('/input2/1/note/1', mock.otherCallback)

    expect(mock.callback).not.toHaveBeenCalled()

    results = legato.dispatch('/input1/1/note/1', 10)

    expect(results.length).toBe(3, 'Only some of the routes should have matched.')
    expect(mock.callback.calls.length).toBe(3, 'The mock callback should have been called 3 times.')
    expect(mock.otherCallback).not.toHaveBeenCalled()

  it 'should allow registration of input ports.', ->
    spyOn(console, 'log') # prevent logs
    spyOn(mock, 'callback')
    spyOn(mock, 'otherCallback')

    portMock =
      onMessage: (cb) ->
        portMock.doStuff = cb
        return true

    legato.in('/input1', portMock.onMessage)

    legato.on('/input1/1/note/1', mock.callback)
    legato.on('/input1/:/note/1', mock.callback)
    legato.on('/input1/:/note/2', mock.otherCallback)
    legato.on('/:/:/:/:', mock.callback)
    legato.on('/input2/1/note/1', mock.otherCallback)

    expect(mock.callback).not.toHaveBeenCalled()

    portMock.doStuff.apply( portMock, ['/1/note/1', 10])

    expect(mock.callback.calls.length).toBe(3, 'Only the three matching callbacks should have been executed.')
    expect(mock.otherCallback).not.toHaveBeenCalled()
