`import Ember from 'ember'`
`import HelpersMixin from 'insight-sports/mixins/helpers'`
`import { animate } from 'ember-animatable'`

ActionsCellComponent = Ember.Component.extend HelpersMixin,
  classNames: ['action-cell']

  api:        Ember.inject.service()
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

  hasStamps: Ember.computed.gt('count', 0)
  duration: Ember.computed.readOnly('appPresets.videoDuration')

  colorClass: Ember.computed 'model.playerNumber', 'count', ->
    if Em.isEqual(@get('model.playerNumber'), '99999')
      return 'green-text text-accent-3'

    if @get('count') == '-'
      "bad"
    else
      "teal-text text-accent-2"

  actionId: Ember.computed 'model.id', 'type', ->
    "#{@get('model.id')}-#{@get('type')}"

  playerNumber: Ember.computed 'model.playerNumber', ->
    number = @get('model.playerNumber')
    if number == "99999"
      'Total'
    else
      number = number + ""
      while (number.length < 2)
        number = "0" + number

      number

  count: Ember.computed "model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.count", 'type', ->
    type = @get('type')
    count = @get("model.#{type}.count")
    if Em.isEqual(count, 0)
      count = '-'

    count

  stamps: Ember.computed 'model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.stamps', 'type', ->
    type = @get('type')
    @get("model.#{type}.stamps")

  actions:
    clicked: (model, actionTime) ->
      time = parseInt(actionTime)
      ytid = model.get('videoPath')
      duration = parseInt(@get('duration') ? 10)

      @setProperties
        'playerVars.start': time
        'playerVars.end':   time + duration
        'videoId':          @youTubeGetID(ytid)

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

`export default ActionsCellComponent`
