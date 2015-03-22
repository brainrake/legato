'use strict'

sandbox = require('./utils').sandbox
_ = require 'lodash'

describe 'legatoRouter', ->
  legato = {}
  legatoUtils = {}
  mock = {}

  beforeEach ->

    legatoUtils = sandbox( 'lib/utils.coffee',
      console: console
    ).utils
    legatoUtils.inject _

    legato = sandbox( 'lib/router.coffee',
      console: console
    ).router
    legato.inject legatoUtils

    mock =
      callback: ->
        return 1
      otherCallback: ->
        return 2

    spyOn console, 'log' # prevent logs

  it 'should call all of the closeted callbacks on deinit', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'The closet should start out empty.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

    legatoUtils.store mock.callback, 0
    legatoUtils.store mock.otherCallback, 1
    expect(Object.keys(legatoUtils.closet).length).toBe 2, 'The closet should have our callback.'

    legato.deinit()
    expect(mock.callback).toHaveBeenCalled()
    expect(mock.otherCallback).toHaveBeenCalled()
    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'The closet should have been cleared.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

  it 'should be possible to reinitialize legato', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'The closet should start empty.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

    legatoUtils.store mock.callback, 0
    legatoUtils.store mock.otherCallback, 1

    expect(Object.keys(legatoUtils.closet).length).toBe 2, 'The closet should contain both callbacks.'

    returned = legato.init()

    expect(mock.callback).toHaveBeenCalled()
    expect(mock.otherCallback).toHaveBeenCalled()
    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'The closet should have been emptied.'
    expect(returned).toBe legato, 'The legato object should be returned from init.'
    expect(Object.keys(legato.routes).length).toBe 0, 'The routes should be cleared.'

  it 'should be able to add new routes.', ->
    expect(Object.keys(legato.routes).length).toBe 0, 'It should start without any routes.'

    id = legato.on '/input1/1/note/1', mock.callback

    expect(Object.keys(legato.routes).length).toBe 1, 'It should have added a new route.'
    expect(typeof id).toBe 'number', 'The id of the route should have been returned.'
    expect(legato.routes[id][0]).toBe '^/input1/1/note/1$', 'The route pattern should be set.'

    id2 = legato.on '/input1/2/note/2', mock.otherCallback

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

    legato.removeRoute (id2)

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
        return -> return true

    inputId = legato.in '/input1', portMock.onMessage

    legato.on '/input1/1/note/1', mock.callback
    legato.on '/input1/:/note/1', mock.callback
    legato.on '/input1/:/note/2', mock.otherCallback
    legato.on '/:/:/:/:', mock.callback
    legato.on '/input2/1/note/1', mock.otherCallback

    expect(mock.callback).not.toHaveBeenCalled()
    expect(typeof(inputId)).toBe 'string', 'It should have returned the id of the input port created.'

    portMock.doStuff.apply portMock, ['/1/note/1', 10]

    expect(mock.callback.calls.length).toBe 3, 'Only the three matching callbacks should have been executed.'
    expect(mock.otherCallback).not.toHaveBeenCalled()

  it 'should allow registration of input ports without a prefix.', ->
    spyOn mock, 'callback'

    portMock =
      onMessage: (cb) ->
        portMock.doStuff = cb
        return -> return true

    inputId = legato.in portMock.onMessage

    legato.on "#{inputId}/:/:/:", mock.callback

    expect(mock.callback).not.toHaveBeenCalled()

    portMock.doStuff.apply portMock, ['/1/note/1', 10]

    expect(mock.callback).toHaveBeenCalled()

  it 'should be possible to remove input ports.', ->
    spyOn mock, 'callback'
    spyOn mock, 'otherCallback'

    portMock1 =
      onMessage: (cb) ->
        portMock1.doStuff = cb
        return -> return true

    portMock2 =
      onMessage: (cb) ->
        portMock2.doStuff = cb
        return -> return true

    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'The closet should start out empty.'

    inputId1 = legato.in '/input1', portMock1.onMessage
    legato.on "/input1/:/:/:", mock.callback
    legato.on "/input1/1/note/:", mock.callback

    expect(Object.keys(legatoUtils.closet).length).toBe 1, 'The closet should contain a shutdown method.'

    inputId2 = legato.in portMock2.onMessage
    legato.on "#{inputId2}/:/:/:", mock.otherCallback

    expect(Object.keys(legatoUtils.closet).length).toBe 2, 'The second shutdown method should have been added.'

    portMock1.doStuff.apply portMock1, ['/1/note/1', 10]

    expect(mock.callback.calls.length).toBe 2, 'The mock callback should have been called.'

    legato.removeInput inputId1, '/input1'

    expect(Object.keys(legatoUtils.closet).length).toBe 1, 'Only one of the shutdown methods should remain.'
    expect(Object.keys(legato.routes).length).toBe 1, 'The routes for input 2 should still remain.'

    portMock1.doStuff.apply portMock1, ['/1/note/1', 10]
    portMock2.doStuff.apply portMock2, ['/1/note/1', 10]

    expect(mock.callback.calls.length)
      .toBe 2, 'The mock callback should not have been called after the input is removed.'
    expect(mock.otherCallback.calls.length)
      .toBe 1, 'The other mock callback should still be functioning.'

    legato.removeInput inputId2

    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'There should not be any shutdown methods left.'
    expect(Object.keys(legatoUtils.closet).length).toBe 0, 'All of the routes should have been removed.'
