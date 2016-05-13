`import Ember from 'ember'`
`import WebsocketMixin from 'insight-sports/mixins/websocket'`
`import { columns, customClasses } from 'insight-sports/constants/monitor-table'`

MonitorController = Ember.Controller.extend WebsocketMixin,
  columns:       columns
  customClasses: customClasses
  session:       'test1'

  init: ->
    @_super(arguments...)
    @updateData(@get('session'))

  updateData: (sessionName) ->
    params =
      session: sessionName

    @store.query('stat', params).then (stats) =>
      @set('model', stats)

`export default MonitorController`
