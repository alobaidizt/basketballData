`import Ember from 'ember'`
`import HelpersMixin from 'insight-sports/mixins/helpers'`

PlayerCellComponent = Ember.Component.extend HelpersMixin,
  tagName: 'td'

  api:                Ember.inject.service()
  appPresets: Ember.inject.service('app-presets')

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
  duration: Ember.computed.readOnly('appPresets.videoDuration')

  actionId: Ember.computed 'model.{id,playerNumber}', ->
    "#{@get('model.id')}-player-#{@get('model.playerNumber')}"

  colorClass: Ember.computed 'model.playerNumber', 'count', ->
    if Em.isEqual(@get('model.playerNumber'), '99999')
      'green-text text-accent-3'
    else
      'gold'

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

  actions:
    clicked: (uri, actionTime) ->
      time = parseInt(actionTime)
      duration = parseInt(@get('duration') ? 10)

      @setProperties
        'playerVars.start': time
        'playerVars.end':   time + duration
        'videoId':          @youTubeGetID(uri)

      @emberYoutube?.player?.loadVideoById
        videoId:          @get('videoId')
        startSeconds:     time
        endSeconds:       time + 10
        suggestedQuality: 'medium'

    openModal: ->
      modelId = "##{@get('actionId')}"
      $(modelId).openModal()

    close: ->
      @emberYoutube?.player?.stopVideo()
      modelId = "##{@get('actionId')}"
      $(modelId).closeModal()

`export default PlayerCellComponent`
