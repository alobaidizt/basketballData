`import Ember from 'ember'`

LogicMixin = Ember.Mixin.create

  checkForDuplicates: false
  getTimestampsFromVideo: true

  init: ->
    @_super()

    config =
      maxAlternatives:   4
      continuous:        true
      interimResults:    true
      lang:              'en-US'

    @get('recognition').createRecognizer(config)
    @get('recognition').bindEvent('onresult',Em.run.bind(this, @_onResult))

    @getData()

  getData: ->
    @get('api').getAppConfig().then ({ config }) =>
      @setProperties
        config:            config
        detectableActions: config.detectableActions
        stitches:          config.stitchesHash
        delay:             config.actionCaptureDelay

    @get('api').getAllKeywords()
      .then ({keywords}) =>
        @set('keywords', keywords.map (word) -> word.name)
        @set('replacements', keywords.map (word) -> new Array(word.name, word.masks))
  _onResult: (event) ->
    interimText   = ''
    resultArray   = new Array() # local scope
    resultIndex   = event.resultIndex
    @setProperties
      output:       []
      outputTS:     []

    while resultIndex < event.results.length
      if event.results[resultIndex].isFinal
        @set('isIdle', true)
        setTimeout((() =>
          if @get('isIdle')
            @get('rec').stop()
        ) , 2000)
        @set 'tsPointer', null # used in recordTS method
        for result,i in event.results[resultIndex]
          resultArray[i] = result.transcript
      else
        @set('isIdle', false)
        interimText += event.results[resultIndex][0].transcript
        @set 'interimText', interimText ? ''
      resultIndex++

    @recordTS(interimText)  if Ember.isPresent(interimText)  # Record Timestamps using interim string
    @filter(resultArray)    if Ember.isPresent(resultArray)

  recordTS: (text) ->
    @secondFilter(text,'timestamp')
    f2 = @get('outputTS')

    if @get('tsPointer')?
      f2 = f2.slice(@get('tsPointer') + 1)

    for word,i in f2
      if @isAction(word)
        @set('tsPointer', i)
        if @get('getTimestampsFromVideo')
          timestamp = @emberYoutube.player.getCurrentTime()
        else
          timestamp = moment().diff(@get('startTime')) / 1000
        @get('timestamps').pushObject([word,timestamp])

  getNextElement: (elements, i) ->
    elements[i]

  isAction: (element) ->
    if @get('detectableActions').indexOf(element) > -1
      true
    else
      false

  isID: (element) ->
    if element.indexOf('number') > -1
      if !(@get('playerIDs').indexOf(element) > -1)
        @get('playerIDs').push(element)
        @get('playersData').push([element])
      true
    else
      false

  getActionTS: (element) ->
    for actionHash,i in @get('timestamps')
      if element == actionHash[0]
        timestamp =  actionHash[1]
        if element == "pass"
          @set('lastPassTS', timestamp)
        @get('timestamps').splice(i, 1)
        return timestamp

  getActionParamsType: (element) ->
    beforeType = ['make','attempt','miss','shoot','attempt','score','take','lose','rebound','turnover','assist','foul','steal']
    afterType = ['turnover-on','turnover-for','foul-by','steal-for','rebound-for','rebound-by','steal-for','steal-by','turnover-by']
    bothType = ['pass','inbound','bounce']
    if beforeType.indexOf(element) > -1
      return "before"
    else if afterType.indexOf(element) > -1
      "after"
    else if bothType.indexOf(element) > -1
      "both"

  setContext: (arr,lastPlayer, current_i,type, action, timestamp) ->
    context = []
    @statObj =
      subject:    null
      videoRef:   @get('videoUrl')
      sessionId:  @get('sessionId')
      actionType: type
      timestamp:  timestamp
    contextComplete = false
    if type == "before"
      if Em.isEqual(action,'assist')

        @statObj.subject = @formatPlayer(@get('assistingPlayer'))
        @statObj.timestamp = timestamp
        @addActionToPlayer(@get('assistingPlayer'), action)
      else
        context.push(lastPlayer)
        @statObj.subject = @formatPlayer(lastPlayer) unless @possibleDuplicateAction(@get('currentSubject'), action)
        @set('currentSubject', lastPlayer)
        @addActionToPlayer(lastPlayer, action) unless @possibleDuplicateAction(@get('currentSubject'), action)
      while (!contextComplete)
        context.push(arr[current_i++])
        if ((action == "make") && (arr[current_i - 1] == "attempt")) || ((action == "attempt") && (arr[current_i - 1] == "make")) || ((action == "attempt") && (arr[current_i - 1] == "assist"))
          context.pop()
        if typeof (arr[current_i]) == 'undefined'
          currentIndex = current_i - 1
          contextComplete = true
          break
        if @isAction(arr[current_i]) || @isID(arr[current_i])
          currentIndex = current_i
          unless ((action == "make") && (arr[current_i] == "attempt")) || ((action == "attempt") && (arr[current_i] == "make")) || ((action == "attempt") && (arr[current_i] == "assist"))
            contextComplete = true
          if @isAction(arr[current_i])
            @set('checkForDuplicates', true)
          if @isID(arr[current_i])
            @set('checkForDuplicates', false)
    else if type == "after"
      while (!contextComplete)
        context.push(arr[current_i++])
        if (typeof (arr[current_i]) == 'undefined')
          currentIndex = current_i - 1
          contextComplete = true
          break
        if (@isID(arr[current_i]))
          playerID = arr[current_i]
          context.push(playerID)
          @statObj.subject = @formatPlayer(playerID) unless @possibleDuplicateAction(@get('currentSubject'), action)
          @set('currentSubject', playerID)
          @addActionToPlayer(playerID, action) unless @possibleDuplicateAction(@get('currentSubject'), action)
          @set('lastID', playerID)
          currentIndex = current_i
          contextComplete = true
          @set('checkForDuplicates', false)
        else if (@isAction(arr[current_i]))
          currentIndex = current_i
          contextComplete = true
          @set('checkForDuplicates', true)
    else if (type == "both")
      context.push(lastPlayer)
      @statObj.subject = @formatPlayer(lastPlayer) unless @possibleDuplicateAction(@get('currentSubject'), action)
      @set('currentSubject', lastPlayer)
      @set('assistingPlayer', lastPlayer) if Em.isEqual(action,'pass')
      @addActionToPlayer(lastPlayer, action) unless @possibleDuplicateAction(@get('currentSubject'), action)
      while (!contextComplete)
        context.push(arr[current_i++])
        if (typeof (arr[current_i]) == 'undefined')
          currentIndex = current_i - 1
          contextComplete = true
          break
        if (@isID(arr[current_i]))
          playerID = arr[current_i]
          context.push(playerID)
          @set('lastID', playerID)
          currentIndex = current_i
          contextComplete = true
          @set('checkForDuplicates', false)
        else if (@isAction(arr[current_i]))
          currentIndex = current_i
          contextComplete = true
          @set('checkForDuplicates', true)
    @set('context', context)

    @statObj.localContext = context
    @statObj.localContext.join(',')
    @_actionSet = false

    @_setActionForStat ['assist'],  'assist', context
    @_setActionForStat ['attempt','two-points'],  'twoPointAttempt', context
    @_setActionForStat ['miss','two-points'],  'twoPointAttempt', context
    @_setActionForStat ['make','two-points'],  'twoPointMade', context
    @_setActionForStat ['make'],  'twoPointMade', context
    @_setActionForStat ['attempt','three-points'],  'threePointAttempt', context
    @_setActionForStat ['miss','three-points'],  'threePointAttempt', context
    @_setActionForStat ['make','three-points'],  'threePointMade', context
    @_setActionForStat ['make'],  'threePointMade', context
    @_setActionForStat ['attempt','free-throw'],  'freeThrowAttempt', context
    @_setActionForStat ['attempt','1st'],  'freeThrowAttempt', context
    @_setActionForStat ['attempt','2nd'],  'freeThrowAttempt', context
    @_setActionForStat ['attempt','3rd'],  'freeThrowAttempt', context
    @_setActionForStat ['miss','free-throw'],  'freeThrowAttempt', context
    @_setActionForStat ['miss','1st'],  'freeThrowAttempt', context
    @_setActionForStat ['miss','2nd'],  'freeThrowAttempt', context
    @_setActionForStat ['miss','3rd'],  'freeThrowAttempt', context
    @_setActionForStat ['make','free-throw'],  'freeThrowMade', context
    @_setActionForStat ['make','1st'],  'freeThrowMade', context
    @_setActionForStat ['make','2nd'],  'freeThrowMade', context
    @_setActionForStat ['make','3rd'],  'freeThrowMade', context
    @_setActionForStat ['make'],  'freeThrowMade', context
    @_setActionForStat ['turnover-on'],  'turnover', context
    @_setActionForStat ['turnover-for'], 'turnover', context
    @_setActionForStat ['turnover-by'], 'turnover', context
    @_setActionForStat ['turnover'], 'turnover', context
    @_setActionForStat ['foul-by'],      'foul', context
    @_setActionForStat ['foul'],      'foul', context
    @_setActionForStat ['steal-for'],    'steal', context
    @_setActionForStat ['steal-by'],     'steal', context
    @_setActionForStat ['steal'],     'steal', context
    @_setActionForStat ['rebound-for'],  'rebound', context
    @_setActionForStat ['rebound-by'],  'rebound', context
    @_setActionForStat ['rebound'],  'rebound', context
    @_setActionForStat ['pass'],  'pass', context

  _setActionForStat: (keywordArr, action, arr) ->
    if @_actionSet
      return
    if keywordArr.length == 1 && keywordArr[0] == 'make'
      if @lastStatAction?.includes(action.substring(0, action.length - 4)) && RegExp(/make/, 'i').test(@statObj.localContext)
        @_actionSet = true
        @statObj.action = action
        @lastStatAction = action
        return
    else
      pattern = keywordArr
        .map (word) -> "(?=.*#{word})"
        .join('')
      if RegExp(pattern, 'gi').test(@statObj.localContext)
        @_actionSet = true
        @statObj.action = action
        @lastStatAction = action

  addActionToPlayer: (playerID, action) ->
    for id,i in @get('playerIDs')
      if Em.isEqual(id,playerID)
        @get('playersData')[i].push(action)

  possibleDuplicateAction: (currentSubject, action) ->
    unless @get('checkForDuplicates')
      return false

    if Em.isEqual(action,'make')
      return false

    if !@get('previousAction')?
      return false

    longerAction = ''
    shorterAction = ''
    if action.length > @get('previousAction').length
      longerAction = action
      shorterAction = @get('previousAction')
    else
      shorterAction = action
      longerAction = @get('previousAction')

    return true if Em.isEqual(@get('previousSubject'), currentSubject) && longerAction.includes(shorterAction)
    false

  replaceAll: (find, replace, str) ->
    return str.replace(new RegExp(find, 'g'), replace)

  isNumber: (n) ->
    return !isNaN(parseFloat(n)) && isFinite(n)

  formatPlayer: (playerId) ->
    number = parseInt(playerId?.match(/\d+/))
    number = number + ""
    while (number.length < 2)
      number = "0" + number
    number

  getText: (structData) ->
    for arr in structData
      timestamp = arr[1]
      playerID = arr[2]
      if playerID?.indexOf('#') < 0
        playerID = arr[arr.length - 1]
      dataOut = arr.slice(2).join()

      if dataOut.indexOf('make') >= 0 && dataOut.indexOf('free-throw') >= 0
        console.log playerID + " attempted a free throw at " + timestamp
        console.log playerID + " made a free throw at " + timestamp
      if dataOut.indexOf('miss') >= 0 && dataOut.indexOf('free-throw') >= 0
        console.log playerID + " attempted a free throw at " + timestamp
        console.log playerID + " missed a free throw at " + timestamp
      if dataOut.indexOf('shoot') >= 0 && dataOut.indexOf(',3') >= 0
        console.log playerID + " attempted a 3-point shot at " + timestamp
      if dataOut.indexOf('shoot') >= 0 && dataOut.indexOf(',2') >= 0
        console.log playerID + " attempted a 2-point shot at " + timestamp
      if dataOut.indexOf('make') >= 0 && dataOut.indexOf(',3') >= 0
        console.log playerID + " made a 3-point shot at " + timestamp
      if dataOut.indexOf('make') >= 0 && dataOut.indexOf(',2') >= 0
        console.log playerID + " made a 2-point shot at " + timestamp
      if dataOut.indexOf('foul-by') >= 0 || dataOut.indexOf('foul-on') >= 0
        fouledPlayerBeginn = dataOut.substring(dataOut.indexOf('foul'))
        console.log fouledPlayerBeginn
        fouledPlayerBegin = fouledPlayerBeginn.indexOf('#')
        console.log fouledPlayerBegin
        fouledPlayerEnd = dataOut.substring(fouledPlayerBegin).indexOf(',')
        console.log fouledPlayerEnd
        if fouledPlayerEnd > -1
          fouledPlayer = dataOut.substring(fouledPlayerBegin, fouledPlayerEnd)
          console.log fouledPlayer
        else
          fouledPlayer = dataOut.substring(fouledPlayerBegin)
          console.log fouledPlayer
        console.log "Foul on " + fouledPlayer + " at " + timestamp

`export default LogicMixin`
