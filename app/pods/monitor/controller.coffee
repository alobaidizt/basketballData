`import Ember from 'ember'`
`import WebsocketMixin from 'insight-sports/mixins/websocket'`
`import { columns, customClasses } from 'insight-sports/constants/monitor-table'`

MonitorController = Ember.Controller.extend WebsocketMixin,
  columns:       columns
  customClasses: customClasses
  session:       'test1'

  api:           Ember.inject.service()
  
  init: ->
    @_super(arguments...)
    @websocketHandler()

  websocketHandler: (event) ->
    params =
      session: @get('session')

    @store.query('stat', params).then (stats) =>
      @set('model', stats)

`export default MonitorController`
