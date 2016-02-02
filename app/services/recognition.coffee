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

    @_initEventHandlers(recognition)

  _initEventHandlers: (recognition) ->
    recognition.onstart = ( ->
      console.log('recognition started'))

    recognition.onstop = ( ->
      console.log('recognition stopped'))

    recognition.onnomatch = ( ->
      console.log('recognition no match'))

    recognition.onaudiostart = ( ->
      console.log('audio started'))

    recognition.onaudioend = ( ->
      console.log('audio ended'))

    recognition.onend = () =>
      console.log('recognition ended')
      console.log @get('isListening')
      recognition.start() if Em.isEqual(@get('isListening'), true)

    recognition.onerror = ((event) ->
      console.log('recognition errored')
      console.log 'error: ', event.error
      console.log 'event object: ', event)

    recognition.onspeechstart = (() ->
      console.log('speech started'))

    recognition.onspeechend = (() ->
      console.log('speech ended'))

    recognition.onsoundstart = (() ->
      console.log('sound started'))

    recognition.onsoundend = (() =>
      console.log('sound ended'))

  createRecognizer: (config) ->
    recognition = new webkitSpeechRecognition()
    console.log('recognition about to start')

    for prop,val of config
      recognition[prop] = val
    @_initEventHandlers(recognition)
    return recognition

  bindEvent: (recognition, event, func) ->
    recognition[event] = func

`export default RecognitionService`
