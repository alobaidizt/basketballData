WebsocketMixin = Ember.Mixin.create
  init: ->
    @_super(arguments...)
    @willRender()

  willRender: ->

    @set 'socket', io(window.webService.websocket)
    @get('socket').on('update', (data) =>
      @updateDataHandler(data))

  updateDataHandler: ({session}) ->
    @updateData?(session)

`export default WebsocketMixin`
