'use strict'

# TODO Integrate with Travis

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
        return 1
      otherCallback: ->
        return 2

    spyOn console, 'log' # prevent logs

  it 'should be able to write legato logs.', ->
    legato.___()
    expect(console.log).toHaveBeenCalledWith('[legato]')

    legato.___ 'blah'
    expect(console.log).toHaveBeenCalledWith('[legato]', 'blah')

    legato.___ 'foo', 'bar', 1, true, null
    expect(console.log.calls[2].args).toEqual(['[legato]','foo','bar',1,true,null])

  it 'should allow adding of callbacks to the closet', ->
    expect(legato.closet.length).toBe 0, 'The closet should start out empty.'
    legato.store mock.callback
    expect(legato.closet.length).toBe 1, 'The closet should have a callback in it.'

  it 'should call all of the closeted callbacks on deinit', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    expect(legato.closet.length).toBe 0, 'The closet should start out empty.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

    legato.store mock.callback
    legato.store mock.otherCallback
    expect(legato.closet.length).toBe 2, 'The closet should have our callback.'

    legato.deinit()
    expect(mock.callback).toHaveBeenCalled()
    expect(mock.otherCallback).toHaveBeenCalled()
    expect(legato.closet.length).toBe 0, 'The closet should have been cleared.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

  it 'should be possible to reinitialize legato', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    expect(legato.closet.length).toBe 0, 'The closet should start empty.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

    legato.store mock.callback
    legato.store mock.otherCallback
    returned = legato.init()

    expect(mock.callback).toHaveBeenCalled()
    expect(mock.otherCallback).toHaveBeenCalled()
    expect(legato.closet.length).toBe 0, 'The closet should have been emptied.'
    expect(returned).toBe legato, 'The legato object should be returned from init.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

  it 'should provide access to the _.throttle method', ->
    spyOn _, 'throttle'
    expect(_.throttle).not.toHaveBeenCalled()

    legato.throttle 100, mock.callback
    expect(_.throttle).toHaveBeenCalledWith mock.callback, 100

  it 'should provide access to the _.delay method.', ->
    spyOn _, 'delay'
    expect(_.delay).not.toHaveBeenCalled()

    legato.delay 100, mock.callback
    expect(_.delay).toHaveBeenCalledWith mock.callback, 100

  it 'should be able to add new routes.', ->
    expect(Object.keys(legato.routes).length).toBe 0, 'It should start without any routes.'

    id = legato.on '/input1/1/note/1', mock.callback

    expect(console.log).toHaveBeenCalled()
    expect(Object.keys(legato.routes).length).toBe 1, 'It should have added a new route.'
    expect(typeof id).toBe 'number', 'The id of the route should have been returned.'
    expect(legato.routes[id][0]).toBe '^/input1/1/note/1$', 'The route pattern should be set.'

    id2 = legato.on '/input1/2/note/2', mock.otherCallback

    expect(console.log.calls.length).toBe 2, 'It should have sent two log messages.'
    expect(Object.keys(legato.routes).length).toBe 2, 'It should have added another route.'
    expect(legato.routes[id2][0]).toBe '^/input1/2/note/2$', 'The route pattern should be set.'

  it 'should be able to create strict routes.', ->
    id = legato.on '/input1/1/note/1', mock.callback

    route = legato.routes[id][0]

    expect(('/input1/1/note/1').match(route).length)
      .toBe 1, 'The path stored should match our route exactly.'
    expect(('/input1/1/note/12').match(route))
      .toBeNull 'The path should not match if the notes are different.'
    expect(('/input2/1/note/1').match(route))
      .toBeNull 'The path should not match if the input is different.'
    expect(('/input1/2/note/1').match(route))
      .toBeNull 'The path should not match if the channels are different.'
    expect(('/input1/1/cc/1').match(route))
      .toBeNull 'The path should not match if the note type is different.'

  it 'should be able to create routes to match any channel', ->
    id = legato.on '/input1/:/note/1', mock.callback

    route = legato.routes[id][0]

    expect(('/input1/1/note/1').match(route).length)
      .toBeGreaterThan 1, 'Events on channel one should match.'
    expect(('/input1/16/note/1').match(route).length)
      .toBeGreaterThan 1, 'Events on any channel should match.'
    expect(('/input2/1/note/1').match(route))
      .toBeNull 'Events on different inputs should not match.'
    expect(('/input1/1/cc/1').match(route))
      .toBeNull 'Events with different types should not match.'

  it 'should be able to create routes to match anything.', ->
    id = legato.on '/:/:/:/:', mock.callback

    route = legato.routes[id][0]

    expect(('/input3/2/cc/7').match(route)).not.toBeNull 'Any input event should match.'
    expect(('/input1/1/note/1').match(route)).not.toBeNull 'Any input event should match.'

  it 'should be possible to remove routes', ->
    id1 = legato.on '/input1/1/note/1', mock.callback
    id2 = legato.on '/input1/1/note/1', mock.otherCallback
    id3 = legato.on '/input1/2/note/2', mock.callback
    id4 = legato.on '/input3/1/note/1', mock.callback

    expect(Object.keys(legato.routes).length).toBe 4, 'There should be 4 routes configured.'

    legato.remove id2

    expect(Object.keys(legato.routes).length).toBe 3, 'The second route should have been removed.'
    expect(legato.routes[id2]).not.toBeDefined()
    expect(legato.routes[id1]).toBeDefined()
    expect(legato.routes[id1][1]).toBe mock.callback

  it 'should dispatch to the correct paths.', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    legato.on '/input1/1/note/1', mock.callback
    legato.on '/input1/:/note/1', mock.callback
    legato.on '/input1/:/note/2', mock.otherCallback
    legato.on '/:/:/:/:', mock.callback
    legato.on '/input2/1/note/1', mock.otherCallback

    expect(mock.callback).not.toHaveBeenCalled()

    results = legato.dispatch '/input1/1/note/1', 10

    expect(results.length).toBe 3, 'Only some of the routes should have matched.'
    expect(mock.callback.calls.length).toBe 3, 'The mock callback should have been called 3 times.'
    expect(mock.otherCallback).not.toHaveBeenCalled()

  it 'should allow registration of input ports.', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    portMock =
      onMessage: (cb) ->
        portMock.doStuff = cb
        return true

    legato.in '/input1', portMock.onMessage

    legato.on '/input1/1/note/1', mock.callback
    legato.on '/input1/:/note/1', mock.callback
    legato.on '/input1/:/note/2', mock.otherCallback
    legato.on '/:/:/:/:', mock.callback
    legato.on '/input2/1/note/1', mock.otherCallback

    expect(mock.callback).not.toHaveBeenCalled()

    portMock.doStuff.apply portMock, ['/1/note/1', 10]

    expect(mock.callback.calls.length).toBe 3, 'Only the three matching callbacks should have been executed.'
    expect(mock.otherCallback).not.toHaveBeenCalled()
