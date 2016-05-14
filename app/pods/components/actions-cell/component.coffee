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
        suggestedQuality: 'large'

`export default ActionsCellComponent`
