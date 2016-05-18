`import Ember from 'ember'`

LogicMixin = Ember.Mixin.create

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
    @get('api').getDetectableActions().then ({actions}) =>
      @set 'detectableActions', actions
    @get('api').getStitches().then ({stitches}) =>
      @set 'stitches', stitches
    
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
          console.log 'is idle: ', @get('isIdle')
          if @get('isIdle')
            @get('rec').stop()
            @get('rec').start()
        ) , 2000)
        @set 'tsPointer', null # used in recordTS method
        for result,i in event.results[resultIndex]
          resultArray[i] = result.transcript
      else
        @set('isIdle', false)
        interimText += event.results[resultIndex][0].transcript
        console.log interimText
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
        timestamp = @emberYoutube.player.getCurrentTime()
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
        @get('timestamps').splice(i,1)
        return timestamp

  getActionParamsType: (element) ->
    beforeType = ['make','attempt','2pt-attempt','miss','grab','shoot','attempt','score','take','lose','layup','rebound','turnover','assist','foul', 'steal']
    afterType = ['turnover-on','turnover-for','foul-on','foul-by','no-basket-for','steal-for','layup-for','rebound-for','rebound-by', 'steal-for', 'steal-by']
    bothType = ['pass','inbound','bounce']
    if beforeType.indexOf(element) > -1
      return "before"
    else if afterType.indexOf(element) > -1
      "after"
    else if bothType.indexOf(element) > -1
      "both"

  setContext: (arr,lastPlayer, current_i,type, action) ->
    context = []
    contextComplete = false
    if type == "before"
      if Em.isEqual(action,'assist') && Em.isEqual(@get('lastAction'),'pass')
        @addActionToPlayer(@get('assistingPlayer'), action)
      else
        context.push(lastPlayer)
        @set('currentSubject', lastPlayer)
        @addActionToPlayer(lastPlayer, action) unless @possibleDuplicateAction(@get('currentSubject'), action)
      while (!contextComplete)
        context.push(arr[current_i++])
        if typeof (arr[current_i]) == 'undefined'
          currentIndex = current_i - 1
          contextComplete = true
          break
        if @isAction(arr[current_i]) || @isID(arr[current_i])
          currentIndex = current_i
          contextComplete = true
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
          @set('currentSubject', playerID)
          @addActionToPlayer(playerID, action) unless @possibleDuplicateAction(@get('currentSubject'), action)
          @set('lastID', playerID)
          currentIndex = current_i
          contextComplete = true
        else if (@isAction(arr[current_i]))
          currentIndex = current_i
          contextComplete = true
    else if (type == "both")
      context.push(lastPlayer)
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
        else if (@isAction(arr[current_i]))
          currentIndex = current_i
          contextComplete = true
    @set('context', context)

  addActionToPlayer: (playerID, action) ->
    for id,i in @get('playerIDs')
      if Em.isEqual(id,playerID)
        @get('playersData')[i].push(action)

  possibleDuplicateAction: (currentSubject, action) ->
    if Em.isEqual(action,'make')
      return false

    return true if Em.isEqual(@get('previousSubject'), currentSubject) && Em.isEqual(action, @get('previousAction'))
    false

  replaceAll: (find, replace, str) ->
    return str.replace(new RegExp(find, 'g'), replace)

  isNumber: (n) ->
    return !isNaN(parseFloat(n)) && isFinite(n)










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
