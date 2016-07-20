`import Ember from 'ember'`

WebsocketMixin = Ember.Mixin.create

  init: ->
    @_super(arguments...)
    @willRender()

  willRender: ->
    @socket = io('http://104.131.117.229:7000')
    @socket.on('update', (data) => @updateDataHandler(data))

  updateDataHandler: ({session}) ->
    @updateData(session)

  willDestroyElement: () ->
    @socket.disconnect()

`export default WebsocketMixin`
