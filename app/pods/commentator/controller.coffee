`import Ember from 'ember'`
`import moment from 'moment'`
`import LogicMixin from 'insight-sports/mixins/logic'`
`import FiltersMixin from 'insight-sports/mixins/filters'`
`import HelpersMixin from 'insight-sports/mixins/helpers'`

CommentatorController = Ember.Controller.extend LogicMixin, FiltersMixin, HelpersMixin,

  api:           Ember.inject.service()
  recognition:   Ember.inject.service()
  notifications: Ember.inject.service('notification-messages')

  local: Em.computed 'localStream', ->
    if @get('localStream') == 'on'
      true
    else
      false

  showScript:	      false
  showResult:       false
  detectedActions:  []
  playerIDs:        []
  playersData:      []
  replacements:     []
  linksArray:       []
  timestamps:       []
  lastID:           undefined
  lastID_i:   	    undefined
  lastAction:       undefined
  currentElement:   undefined
  interimText:      ''
  finalText:        ''
  structuredData:   new Array()
  tsPointer:        null       # Timestamp pointer
  ytPlayer:         {}
  keywords:         []
  finalResults_i: 0 # used in filter 3
  videoUrl:       "https://www.youtube.com/watch?v=xMknfpleSho"
  localUrl:       "http://127.0.0.1:1935/live/myStream/manifest.mpd"
  context: undefined
  startTime: null
  stopTime: null

  showTable:        true
  isListening:      Ember.computed.alias('recognition.isListening')
  rec:              Ember.computed.alias('recognition.recognition')

  yt_id:     Ember.computed 'videoUrl', ->
    @youTubeGetID(@get('videoUrl'))

  videoIconClass: Ember.computed 'isListening', ->
    if @get('isListening')
      'pause_circle_filled'
    else
      'play_circle_filled'

  actions:
    # jwplayer actions
    setupError: (msg) ->
      console.log 'error', msg
    play: (oldState) ->
      console.log 'played', oldState
    pause: (oldState) ->
      console.log 'paused', oldState
    complete: ->
      console.log 'completed'
    buffer: (buffer) ->
      console.log 'buffering', buffer
    startListening: ->
      if Em.isEmpty(@get('sessionId'))
        @addNotification("Must enter a session name first", 3000)
        return false

      recognition = @get('rec')
      status = @get('isListening')
      @toggleProperty('isListening')

      if !status
        @emberYoutube.player?.playVideo()
        recognition.start()
        @set 'startTime', moment()
      else
        @emberYoutube.player?.pauseVideo()
        recognition.stop()
        @set 'stopTime', moment()

    goToCalibrate: ->
      @transitionToRoute('calibration')

`export default CommentatorController`
