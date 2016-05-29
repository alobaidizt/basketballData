`import Ember from 'ember'`

HomeController = Ember.Route.extend
  showGratitude: false

  actions:
    saveEmail: ->
      email = @get('email')
      record = @store.createRecord 'email',
        email: email
      record.save().then =>
        @set 'showGratitude', true


`export default HomeController`
