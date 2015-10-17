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
      console.log result
      if Em.isPresent(currentKeyword)
        if currentKeyword != result
          #@notifications.addNotification
            #message: result
            #type: 'warning'

          @get('api').updateKeywordByName(currentKeyword, result).then =>
            @set('currentKeyword', null)
        #else
          #@notifications.addNotification
            #message: 'Saved successfully!'
            #type: 'success'

    recognition.onstart = ->
      that = window.privateVar
      that.toggleProperty('isListening')
    recognition.onstop  = ->
    recognition.onend   = ->
      that = window.privateVar
      that.toggleProperty('isListening')


`export default RecognitionService`
