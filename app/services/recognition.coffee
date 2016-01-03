`import Ember from 'ember'`

RecognitionService = Ember.Service.extend
  isListening:      false
  currentKeyword:   undefined
  api:              Ember.inject.service()

  setupCalibration: (properties = {}) ->
    recognition = new webkitSpeechRecognition()
    for key, val of properties
      recognition[key] = val

    @set 'recognition', recognition
    window.privateVar = this

    recognition.onresult = (event) =>
      result =  event.results[0][0].transcript
      currentKeyword = @get('currentKeyword')

      if Em.isPresent(currentKeyword) and !Em.isEqual(currentKeyword,result)
        @notifications.addNotification
          message: "Mismatch! Detected: #{result}."
          type: 'warning'
          autoClear: true
          clearDuration: 1200

        @get('api').updateKeywordByName(currentKeyword, result).then =>
          @set('currentKeyword', null)
      else
        @notifications.addNotification
          message: 'Match!'
          type: 'success'
          autoClear: true
          clearDuration: 1200

    recognition.onstart = ->
      that = window.privateVar
      that.toggleProperty('isListening')
    recognition.onstop  = ->
    recognition.onend   = ->
      that = window.privateVar
      that.toggleProperty('isListening')

  createRecognizer: (config) ->
    recognition = new webkitSpeechRecognition()

    for prop,val of config
      recognition[prop] = val
    return recognition



`export default RecognitionService`
