`import Ember from 'ember'`

ApiService = Ember.Service.extend

  getAllKeywords: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: "https://104.131.117.229:444/api/keywords/",
    })

  getKeywordByName: (name) ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: "https://104.131.117.229:444/api/keywords/name/#{name}",
    })

  updateKeywordByName: (name, mask) ->
    # returns a promise
    $.ajax({
      type: "PUT",
      url: "https://104.131.117.229:444/api/keywords/name/#{name}",
      data:
        mask: mask
    })

  addHistoryRecord: (record) ->
    # returns a promise
    size = record.structuredOutput?.length
    $.ajax({
      type: "POST",
      url: "https://104.131.117.229:444/api/histories",
      data:
        timestamp:            record.timestamp
        beforeEnhancement:    record.beforeEnhancement
        afterEnhancement:     record.afterEnhancement
        structuredOutput:     record.structuredOutput
        structuredOutputSize: size
    })

`export default ApiService`
