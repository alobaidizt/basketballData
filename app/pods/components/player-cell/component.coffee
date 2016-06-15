`import Ember from 'ember'`
`import HelpersMixin from 'insight-sports/mixins/helpers'`

PlayerCellComponent = Ember.Component.extend HelpersMixin,
  api:                Ember.inject.service()
  videoId:            null
  playerVars:
      autoplay:       1
      enablejsapi:    1
      autoHide:       1
      modestbranding: 1
      loop:           1
      rel:            0
      showInfo:       0
      controls:       0
      cc_load_policy: 0
      fs:             0
      start:          0
      end:            10

  hasActions: Ember.computed.notEmpty('actions')

  actionCellClass: Ember.computed 'model.{id,playerNumber}', ->
    "#{@get('model.id')}-player-#{@get('model.playerNumber')}"

  playerNumber: Ember.computed 'model.playerNumber', ->
    number = @get('model.playerNumber')
    if number == "99999"
      'Total'
    else
      number = number + ""
      while (number.length < 2)
        number = "0" + number
     
      number

  actionss: Ember.computed 'model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.stamps', 'model.videoPath', ->
    actions = []
    keys = ['assist', 'foul', 'steal', 'rebound', 'turnover', 'twoPointAttempt', 'twoPointMade', 'threePointAttempt', 'threePointMade', 'freeThrowAttempt', 'freeThrowMade']
    uri = @get('model.videoPath')
    keys.forEach (key) =>
      stamps = @get("model.#{key}.stamps")
      if stamps?
        stamps.forEach (stamp) ->
          actions.push(name: key, videoUri: uri, stamp: stamp)
    actions

  init: ->
    @_super(arguments...)

    @get('api').getDuration().then ({duration}) =>
      @set 'duration', duration

  actions:
    clicked: (uri, actionTime) ->
      time = parseInt(actionTime)
      duration = parseInt(@get('duration') ? 10)

      @setProperties
        'playerVars.start': time
        'playerVars.end':   time + duration
        'videoId':          @youTubeGetID(uri)

      @emberYoutube.player.loadVideoById
        videoId:          @get('videoId')
        startSeconds:     time
        endSeconds:       time + 10
        suggestedQuality: 'medium'

    openModal: ->
      modalID = "##{@get('actionCellClass')}"
      $(modalID).openModal()

    close: ->
      @emberYoutube?.player.stopVideo()

      modalID = "##{@get('actionCellClass')}"
      $(modalID).closeModal()

`export default PlayerCellComponent`
