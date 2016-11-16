`import Ember from 'ember'`

ApiService = Ember.Service.extend
  host: window.webService.servicePrefix

  getAllKeywords: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/keywords/",
    })

  updateKeywordByName: (name, mask) ->
    # returns a promise
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/keywords/name/#{name}",
      data:
        mask: mask
    })

  addStitch: (stitchIn, stitchOut) ->
    stitch = {}
    stitch[stitchIn] = stitchOut

    # returns a promise
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/config/stitch",
      data: stitch
    })

  addHistoryRecord: (record) ->
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/histories",
      data:
        session:           record.sessionId
        timestamp:         record.timestamp
        beforeEnhancement: record.beforeEnhancement
        afterEnhancement:  record.afterEnhancement
        structuredOutput:  record.structuredOutput
    })

  getDetectableActions: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config/action"
    })

  getStitches: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config/stitch"
    })

  setDelay: (delay) ->
    # returns a promise
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/config/delay",
      data:
        { delay: delay }
    })

  getDelay: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config/delay",
    })

  setDuration: (duration) ->
    # returns a promise
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/config/duration",
      data:
        { duration: duration }
    })

  getDuration: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config/duration",
    })

  addStat: ({ stat }) ->
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/stats",
      data:
        stat: stat
    })

  getTotals: (session) ->
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/stats/total?session=#{session}",
    })

  getAppConfig: ->
    $.ajax({
      type: "GET",
      url: @get('host') + "/api/config"
    })

  updateAppConfig: (data) ->
    $.ajax({
      type: "POST",
      url: @get('host') + "/api/config"
      data: data
    })

`export default ApiService`
