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

    window.privateVar = this

    recognition.onresult = (event) =>
      that = window.privateVar
      result =  event.results[0][0].transcript
      currentKeyword = @get('currentKeyword')
      console.log currentKeyword
      if Em.isPresent(currentKeyword)
        console.log 0
        if currentKeyword != result
          @get('api').updateKeywordByName(currentKeyword, result).then =>
            @set('currentKeyword', null)




    recognition.onstart = ->
    recognition.onstop  = ->
    recognition.onend   = ->
      that = window.privateVar
      that.toggleProperty('isListening')


`export default RecognitionService`
