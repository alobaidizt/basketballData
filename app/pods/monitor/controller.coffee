`import Ember from 'ember'`
`import WebsocketMixin from 'insight-sports/mixins/websocket'`
`import { columns, customClasses } from 'insight-sports/constants/monitor-table'`

MonitorController = Ember.Controller.extend WebsocketMixin,
  columns:       columns
  customClasses: customClasses
  session:       'test'

  api: Ember.inject.service()

  init: ->
    @_super(arguments...)
    @updateData(@get('session'))

  updateData: (sessionName) ->
    params =
      session: sessionName

    @store.query('stat', params)
      .then (stats) =>
        @set('model', stats)
      .then =>
        @get('api').getTotals(sessionName)
      .then ({ stats }) =>
        totals = stats?[0]
        for key in _.keys(totals)
          if _.has(totals[key], 'players')
            totals[key].players = _.flatMap(totals[key].players)
            totals[key].stamps = _.flatMap(totals[key].stamps)
        record = @store.createRecord('stat', totals)
        model = _.concat(@get('model').toArray().rejectBy('playerNumber', 'Total'), record)
        @set 'model', model

  actions:
    lookupSession: ->
      session   = $('#session-name').val()
      @set 'session', session
      @updateData(session)

    addTotals: (session) ->
      @addTotals()

`export default MonitorController`
