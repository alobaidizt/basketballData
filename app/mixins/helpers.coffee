`import Ember from 'ember'`

HelpersMixin = Ember.Mixin.create
  youTubeGetID: (url) ->
    # @author: takien
    # @url: http://takien.com
    ID = ''
    url = url.replace(/(>|<)/gi,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)
    if (url[2] != undefined)
      ID = url[2].split(/[^0-9a-z_\-]/i)
      ID = ID[0]
    else
      ID = url

  addNotification: (word, duration = 750) ->
    @notifications.addNotification
      message: "#{word}"
      type: 'info'
      autoClear: true
      clearDuration: duration

  getRandomIntInclusive: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min

`export default HelpersMixin`
