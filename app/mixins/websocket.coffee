`import Ember from 'ember'`

WebsocketMixin = Ember.Mixin.create

  init: ->
    @_super(arguments...)
    @willRender()

  willRender: ->
    @set 'socket', io('http://127.0.0.1:7000')
    @get('socket').on('update', (data) =>
      @updateDataHandler(data))

  updateDataHandler: ({session}) ->
    @updateData(session)

`export default WebsocketMixin`
