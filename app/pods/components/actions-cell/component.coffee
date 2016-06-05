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

  colorClass: Ember.computed 'count', ->
    if @get('count') == '-'
      "bad"

  actionCellClass: Ember.computed 'model.id', 'type', ->
    "#{@get('model.id')}-#{@get('type')}"

  count: Ember.computed "model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.count", 'type', ->
    type = @get('type')
    id = @get('model.id')
    count = @get("model.#{type}.count")
    if Em.isEqual(count, 0)
      count = '-'
    
    lastCount = @get("last#{type}")
    if lastCount? and lastCount != count
      Ember.run.scheduleOnce('afterRender', this, '_animate', id, type)
    @set("last#{type}", count)
    count

  stamps: Ember.computed 'model.{assist,foul,steal,rebound,turnover,twoPointAttempt,twoPointMade,threePointAttempt,threePointMade,freeThrowAttempt,freeThrowMade}.stamps', 'type', ->
    type = @get('type')
    @get("model.#{type}.stamps")

  init: ->
    @_super(arguments...)

    $.fn.extend
        animateCss: (animationName) ->
          animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend'
          $(this).addClass('animated ' + animationName).one(animationEnd, () ->
            $(this).removeClass('animated ' + animationName)
          )

  didReceiveAttrs: ({oldAttrs, newAttrs}) ->
    @_super()
    type = @get('type')
    id = @get('model.id')
    if oldAttrs?.model.value.get("#{type}.count") != newAttrs.model.value.get("#{type}.count")
      Ember.run.scheduleOnce('afterRender', this, '_animate', id, type)

  _animate: (id, type) ->
      $("##{id}-#{type}").animateCss('bounce')

  actions:
    clicked: (model, actionTime) ->
      time = parseInt(actionTime)
      ytid = model.get('videoPath')

      @setProperties
        'playerVars.start': time
        'playerVars.end':   time + 10
        'videoId':          @youTubeGetID(ytid)

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

`export default ActionsCellComponent`
