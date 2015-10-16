`import Ember from 'ember'`

ApiService = Ember.Service.extend

  getAllKeywords: ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: "http://104.131.117.229:3000/api/keywords/",
    })

  getKeywordByName: (name) ->
    # returns a promise
    $.ajax({
      type: "GET",
      url: "http://104.131.117.229:3000/api/keywords/name/#{name}",
    })

  updateKeywordByName: (name, mask) ->
    # returns a promise
    $.ajax({
      type: "PUT",
      url: "http://104.131.117.229:3000/api/keywords/name/#{name}",
      data:
        mask: mask
    })
  

`export default ApiService`
