`import Ember from 'ember'`

RecognitionService = Ember.Service.extend
  isListening:      false
  currentKeyword:   undefined
  api:              Ember.inject.service()

  setup: (properties = {}) ->
    recognition = new webkitSpeechRecognition()
    for key, val of properties
      recognition[key] = val

    @set 'recognition', recognition

    recognition.onresult = (event) =>

      result =  event.results[0][0].transcript
      currentKeyword = @get('currentKeyword')

      if Em.isPresent(currentKeyword) and Em.isEqual(currentKeyword,result)
        @notifications.addNotification
          message: "Mismatch! Detected: #{result}."
          type: 'warning'
          autoClear: true

        @get('api').updateKeywordByName(currentKeyword, result).then =>
          @set('currentKeyword', null)
      else
        @notifications.addNotification
          message: 'Match!'
          type: 'success'
          autoClear: true

    recognition.onstart = ->
      @toggleProperty('isListening')
    recognition.onstop  = ->
    recognition.onend   = ->
      @toggleProperty('isListening')

`export default RecognitionService`
