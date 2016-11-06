`import Ember from 'ember'`

RecognitionService = Ember.Service.extend
  isListening:    false
  currentKeyword: undefined
  recognition:    undefined

  api:            Ember.inject.service()
  notifications:  Ember.inject.service('notification-messages')

  setupCalibration: (properties = {}) ->
    recognition = new webkitSpeechRecognition()
    for key, val of properties
      recognition[key] = val

    recognition.onresult = (event) =>
      result =  event.results[0][0].transcript
      currentKeyword = @get('currentKeyword')

      if Em.isPresent(currentKeyword) and !Em.isEqual(currentKeyword,result)
        @get('notifications').warning "Mismatch! Detected: #{result}.",
          autoClear: true
          clearDuration: 1200

        @get('api').updateKeywordByName(currentKeyword, result).then =>
          @set('currentKeyword', null)
      else
        @get('notifications').success 'Match!',
          autoClear: true
          clearDuration: 1200

    @set 'recognition', recognition
    @_initEventHandlers()

  _initEventHandlers: () ->
    recognition = @get 'recognition'
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
    @set 'recognition', recognition

    console.log('recognition about to start')

    for prop,val of config
      @get('recognition')[prop] = val
    @_initEventHandlers()
    return @get('recognition')

  bindEvent: (event, func) ->
    @get('recognition')[event] = func

`export default RecognitionService`
