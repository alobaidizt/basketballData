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

  pad: (num) ->
    ("0"+num).slice(-2)

  hhmmss: (secs) ->
    minutes = Math.floor(secs / 60)
    secs = secs % 60
    hours = Math.floor(minutes / 60)
    minutes = minutes % 60
    @pad(hours) + ":" + @pad(minutes) + ":" + @pad(secs)

`export default HelpersMixin`
