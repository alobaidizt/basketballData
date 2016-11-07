`import Ember from 'ember'`


AppPresetsService = Ember.Service.extend
  videoDuration: null

  api: Em.inject.service()

  init: ->
    @get('api').getDuration().then ({duration}) =>
      @set 'videoDuration', duration

`export default AppPresetsService`
