`import Ember from 'ember'`

WebsocketMixin = Ember.Mixin.create
  #socketService: Ember.inject.service('websockets')
  #webso: Ember.inject.service()

  init: ->
    @_super(arguments...)
    @willRender()
    #socket = io('http://localhost:7000')
    #socket.on('update', (sessionId) -> console.log sessionId)
    #socket.on('updated', (sessionId) -> console.log sessionId)

  willRender: ->
    socket = @get('websockets').socketFor('ws://localhost:7000/')

    socket.on('open',    @wsOpenHandler, this)
    # Override this method in controller
    socket.on('message', @wsMessageHandler, this)
    socket.on('close',   @wsCloseHandler, this)

    @set('socketRef', socket)

  wsOpenHandler: (event) ->
    console.log("On open event has been called: #{event}")
 
  wsMessageHandler: (event) ->
    console.log("Message: #{event.data}")
 
  wsCloseHandler: (event) ->
    console.log("On close event has been called: #{event}")

  willDestroyElement: () ->
    socket = @get('socketRef')
 
    socket.off 'open',    @wsOpenHandler()
    socket.off 'message', @wsMessageHandler()
    socket.off 'close',   @wsCloseHandler()
 
`export default WebsocketMixin`
