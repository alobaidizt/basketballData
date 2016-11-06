`import Ember from 'ember'`

CommentatorRoute = Ember.Route.extend

  clean: ->
    @get('controller').setProperties
      startTime: null
      stopTime: null


  didTransition: ->
    @clean()

`export default CommentatorRoute`
