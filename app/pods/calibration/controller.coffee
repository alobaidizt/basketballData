`import Ember from 'ember'`
CalibrationController = Ember.Controller.extend

  showCalibrationWords: false
  keywords:             undefined
  recognition:          Ember.inject.service()
  api:                  Ember.inject.service()

  isListening:          Ember.computed.alias('recognition.isListening')

  init: ->
    @_super()
    @get('recognition').setupCalibration()

  addData: ->
    params =
      name: $('#name').val().toLowerCase()
      mask: $('#mask').val().toLowerCase()

    @get('api').updateKeywordByName(params.name, params.mask).then ->
      $('#name').val('')
      $('#mask').val('')

  addStitch: ->
    stitchIn    = $('#stitch-in').val().toLowerCase()
    stitchOut   = $('#stitch-out').val().toLowerCase()

    @get('api').addStitch(stitchIn, stitchOut).then ->
      $('#stitch-in').val('')
      $('#stitch-out').val('')

  calibrate: ->
    @get('api').getAllKeywords()
      .then (data) =>
        @set 'keywords', data.keywords
        @toggleProperty('showCalibrationWords')

  actions:
    calibrateWord: (word) ->
      @get('recognition').set('currentKeyword', word)
      @get('recognition').recognition.start()

    addData:   -> @addData()
    addStitch: -> @addStitch()
    calibrate: -> @calibrate()

`export default CalibrationController`
