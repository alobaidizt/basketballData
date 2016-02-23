`import Ember from 'ember'`

ApiService = Ember.Service.extend
  host: window.webService.servicePrefix

  getAllKeywords: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/keywords/",
    })

  getKeywordByName: (name) ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/keywords/name/#{name}",
    })

  updateKeywordByName: (name, mask) ->
    # returns a promise
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/keywords/name/#{name}",
      data:
        mask: mask
    })

  addHistoryRecord: (record) ->
    # returns a promise
    size = record.structuredOutput?.length
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/histories",
      data:
        sessionId:            record.sessionId
        timestamp:            record.timestamp
        beforeEnhancement:    record.beforeEnhancement
        afterEnhancement:     record.afterEnhancement
        structuredOutput:     record.structuredOutput
        structuredOutputSize: size
    })

  getDetectableActions: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config/action",
    })

  getStitches: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config/stitch",
    })

`export default ApiService`
