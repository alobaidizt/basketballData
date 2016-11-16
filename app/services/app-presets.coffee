`import Ember from 'ember'`


AppPresetsService = Ember.Service.extend
  videoDuration: null

  api: Em.inject.service()

  init: ->
    @get('api').getAppConfig().then ({clipDuration}) =>
      @set 'videoDuration', clipDuration

`export default AppPresetsService`
