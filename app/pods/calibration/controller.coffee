`import Ember from 'ember'`

CalibrationController = Ember.Controller.extend

  showCalibrationWords: false
  keywords:             undefined
  recognition:          Ember.inject.service()

  init: ->
    @_super()
    @get('recognition').setup()

  endFunction: ->
    console.log "success"

  addData: ->
    params =
      name: $('#name').val().toLowerCase()
      mask: $('#mask').val().toLowerCase()

    @updateKeywordByName(params.name, params.mask).then ->
      $('#name').val('')
      $('#mask').val('')

  calibrate: ->
    @getAllKeywords()
      .then (data) =>
        @set 'keywords', data.keywords
        @toggleProperty('showCalibrationWords')


  getAllKeywords: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: "http://localhost:3000/api/keywords/",
    })

  getKeywordByName: (name) ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: "http://localhost:3000/api/keywords/name/#{name}",
    })

  updateKeywordByName: (name, mask) ->
    # returns a promise
    $.ajax({
      type: "PUT",
      url: "http://localhost:3000/api/keywords/name/#{name}",
      data:
        mask: mask
    })
  
  actions:
    calibrateWord: (word) ->
      console.log word
      @get('recognition').set('currentKeyword', word)
      @get('recognition').recognition.start()

    addData: -> @addData()
    calibrate: -> @calibrate()

    test: ->
      name = "new"
      mask = "news"
      @updateKeywordByName(name, mask).then (data) ->
        console.log data

`export default CalibrationController`
