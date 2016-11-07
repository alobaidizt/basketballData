`import Ember from 'ember'`

MonitorRoute = Ember.Route.extend

  willTransition: ->
    @get('socket').disconnect()

`export default MonitorRoute`
