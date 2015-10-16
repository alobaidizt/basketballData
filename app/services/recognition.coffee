`import Ember from 'ember'`

RecognitionService = Ember.Service.extend
  isListening:      false
  currentKeyword:   undefined

  setup: (properties = {}) ->
    recognition = new webkitSpeechRecognition()
    for key, val of properties
      recognition[key] = val

    @set 'recognition', recognition

    window.privateVar = this

    recognition.onresult = (event) =>
      that = window.privateVar
      result =  event.results[0][0].transcript
      #if currentKeyword? =! result


    recognition.onstart = ->
    recognition.onstop  = ->
    recognition.onend   = ->
      that = window.privateVar
      that.toggleProperty('isListening')
      #that.endFunction()


`export default RecognitionService`
