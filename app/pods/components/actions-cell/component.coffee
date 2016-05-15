`import Ember from 'ember'`
`import HelpersMixin from 'insight-sports/mixins/helpers'`

ActionsCellComponent = Ember.Component.extend HelpersMixin,
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

  count: Ember.computed "model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.count", 'type', ->
      type = @get('type')
      @get("model.#{type}.count")

  stamps: Ember.computed 'model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.uriLinks', 'type', ->
    type = @get('type')
    @get("model.#{type}.uriLinks")

  actions:
    clicked: (model, actionTime) ->
      time = parseInt(actionTime)
      ytid = model.get('videoPath')

      @setProperties
        'playerVars.start': time
        'playerVars.end':   time + 5
        'videoId':          @youTubeGetID(ytid)

      @emberYoutube.player.loadVideoById
        videoId:          @get('videoId')
        startSeconds:     time
        endSeconds:       time + 5
        suggestedQuality: 'medium'

`export default ActionsCellComponent`
