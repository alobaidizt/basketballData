`import Ember from 'ember'`
`import moment from 'moment'`

SplashController = Ember.Controller.extend

  api:              Ember.inject.service()

  showScript:	      false
  isListening:      false
  showResult:       false
  detectedActions:  []
  playerIDs:        []
  playersData:      []
  keywords:         []
  replacements:     []
  linksArray:       []
  recognition:      undefined
  currentIndex:	    undefined
  lastID:           undefined
  lastID_i:   	    undefined
  currentElement:   undefined
  structuredData:   []
  startTime:        undefined
  endTime:          undefined
  tsPointer:        null       # Timestamp pointer
  videoUrl:         undefined
  finalResults_i:   undefined

  showTable:        true
  #showTable: Ember.computed 'structuredData', ->
    #Ember.isPresent @get('structuredData')

  videoUrl_Mod:     Ember.computed 'videoUrl',
    get: ->
      @get('videoUrl').replace('watch?v=','embed/')
    set: (key,value) ->
      if !value?
        return
      value

  videoIconClass: Ember.computed 'isListening', ->
    if @get('isListening')
      'pause_circle_filled'
    else
      'play_circle_filled'
  duration: Em.computed 'startTime', 'endTime', ->
    @get('endTime').diff(@get('startTime'), 'seconds')

  videoController: Em.observer 'isListening', ->
    #TODO: use youtube-iframe API npm or bower module
    # Video Controls
    videoURL = @get('videoUrl').replace('watch?v=','embed/')
    if @get('isListening')
      @set 'videoUrl_Mod', videoURL + '?autoplay=true'
    else
      @set 'videoUrl_Mod', videoURL

  init: ->
    @_super()
    recognition = new webkitSpeechRecognition()

    recognition.maxAlternatives = 4
    recognition.continuous      = true
    recognition.interimResults  = true

    # TODO: add bbActions to the DB
    bbActions = ['make','miss','grab','pass','lose','shoot','turnover-on','take','foul-by','foul-on','no-basket-for','steal-for','inbound','bounce']
    
    # TODO: remove this

    @get('api').getAllKeywords().then ({keywords}) =>
      keywords.forEach (keyword) =>
        @get('keywords').pushObject(keyword.name)
        @get('replacements').pushObject([keyword.name,keyword.masks])

    # Adding Speech Grammar
    for word in @get('keywords')
      recognition.grammars.addFromString(word)

    # Stiching
    # TODO: add stitches to the DB
    stitches = [['number ','number-'],[' red','-red'],[' blue','-blue'],['turnover on','turnover-on'],['foul by','foul-by'],['foul on','foul-on'],['no basket for','no-basket-for'],['ball to','ball-to'],['ball from','ball-from'],['steal for','steal-for']]


    @setProperties
      recognition:    recognition
      bbActions:      bbActions
      stitches:       stitches
      timestamps:     []
      finalResults_i: 0 # used in filter 3
      videoUrl:       "https://www.youtube.com/watch?v=OY3lSTb_DM0"

    recognition.onresult = ((event) =>
      interimText   = ''
      resultArray   = new Array() # local scope
      resultIndex   = event.resultIndex
      @setProperties
        output:       []
        outputTS:     []

      while resultIndex < event.results.length
        if event.results[resultIndex].isFinal

          @set 'tsPointer', null # used in recordTS method

          for result,i in event.results[resultIndex]
            resultArray[i] = result.transcript

        else
          interimText += event.results[resultIndex][0].transcript
        resultIndex++

      @recordTS(interimText)  if Ember.isPresent(interimText)  # Record Timestamps using interim string

      
      @filter(resultArray)    if Ember.isPresent(resultArray)
    )
    recognition.onstart = ->
    recognition.onstop  = ->
    recognition.onend   = =>
      @get('recognition').start() if Em.isEqual(@get('isListening'), true)

  recordTS: (text) ->
    @secondFilter(text,'timestamp')
    f2 = @get('outputTS')

    if @get('tsPointer')?
      f2 = f2.slice(@get('tsPointer') + 1)

    for word,i in f2
      if @isAction(word)
        @set('tsPointer', i)
        timestamp = moment().format()
        @get('timestamps').push([word,timestamp])

  filter: (results) ->
    @set('detectedActions', [])

    f1r = @firstFilter(results)
    f2r = @secondFilter(f1r,'filter')
    f3r = @thirdFilter(f2r)
    #f4r = @logic(f3r)
    #console.log 'players Data: ', @get('playersData')
    #console.log 'playerIDs: ', @get('playerIDs')

    @get('structuredData').pushObjects(f3r)
    @setProperties
      resultString: f1r
      showResult:   true
    @set 'timestamps', []

  logic: (structData) ->
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


  firstFilter: (results) ->
    # Returns the the best result from the returned results array from the voiceRecognition 
    # service
    scores = new Array()
    for result,i in results
      for keyword in @get('keywords')
        regexStr = new RegExp(keyword,"g")
        count = (result?.toLowerCase().match(regexStr) || []).length
        if (typeof scores[i] == 'undefined')
          scores[i] = 0
        scores[i] += count
    matchedIndex = scores.indexOf(Math.max.apply(Math,scores))
    return results[matchedIndex]?.toLowerCase()

  secondFilter: (f1r, purpose) ->
    for replacement in @get('replacements')
      for mask in replacement[1]
        if (f1r.indexOf(mask) > -1)
          f1r = @replaceAll(mask,replacement[0],f1r)

    for stitch in @get('stitches')
      if (f1r.indexOf(stitch[0]) > -1)
        f1r = @replaceAll(stitch[0],stitch[1],f1r)

    # The text after enhancment
    console.log f1r
    
    parsedResults = f1r.split(" ")

    if purpose == 'filter'
      output = @get('output')
    else if purpose == 'timestamp'
      output = @get('outputTS')

    for parsedResult in parsedResults
      if parsedResult.toString().includes('number')
        output.push(parsedResult)
      if parsedResult.toString().includes('1st')
        output.push(parsedResult)
      if parsedResult.toString().includes('2nd')
        output.push(parsedResult)
      if parsedResult.toString().includes('rebound')
        output.push(parsedResult)
      if parsedResult.toString().includes('inbound')
        output.push(parsedResult)
      if parsedResult.toString().includes('bounce')
        output.push(parsedResult)
      if parsedResult.toString().includes('make')
        output.push(parsedResult)
      if parsedResult.toString().includes('assist')
        output.push(parsedResult)
      if parsedResult.toString().includes('take')
        output.push(parsedResult)
      if parsedResult.toString().includes('miss')
        output.push(parsedResult)
      if parsedResult.toString().includes('grab')
        output.push(parsedResult)
      if parsedResult.toString().includes('lose')
        output.push(parsedResult)
      if parsedResult.toString().includes('pass')
        output.push(parsedResult)
      if parsedResult.toString().includes('shoot')
        output.push(parsedResult)
      if parsedResult.toString().includes('turnover-on')
        output.push(parsedResult)
      if parsedResult.toString().includes('free-throw')
        output.push(parsedResult)
      if parsedResult.toString().includes('no-basket-for')
        output.push(parsedResult)
      if parsedResult.toString().includes('foul-by')
        output.push(parsedResult)
      if parsedResult.toString().includes('foul-on')
        output.push(parsedResult)
      if parsedResult.toString().includes('ball-to')
        output.push(parsedResult)
      if parsedResult.toString().includes('ball-from')
        output.push(parsedResult)
      if parsedResult.toString().includes('steal-for')
        output.push(parsedResult)
      if @isNumber(parsedResult.toString())
        output.push(parsedResult)
    return output

  thirdFilter: (f2r) ->
    #TODO: maybe do this in init?
    @set('currentIndex', 0)

    finalResults    = new Array()
    currentIndex    = @get('currentIndex')
    finalResults_i  = @get('finalResults_i')
    _frIndex = 0

    while currentIndex < (f2r.length - 1)
      currentElement = @getNextElement(f2r, currentIndex)
      if @isID(currentElement)
        @set('lastID', currentElement)
        @set('lastID_i', currentIndex)
        currentIndex++
        currentElement = @getNextElement(f2r, currentIndex)
      if @isAction(currentElement)
        action = currentElement
        actions = @get('detectedActions')
        actions.pushObject(currentElement)
        @set('detectedActions', actions)
        type = @getActionParamsType(currentElement)
        actionTS = @getActionTS(currentElement)
        timeStamp = if actionTS? then actionTS else "-"
        finalResults[_frIndex] = @getContext(f2r, @get('lastID_i'),currentIndex, type, action)
        finalResults[_frIndex].unshift("Item #{finalResults_i + 1}", timeStamp)
        if actionTS?
          timeInSec = moment(actionTS).diff(@startTime, "seconds") - 2
          @get('linksArray')[finalResults_i] = @get('videoUrl') + "#t=" + timeInSec + "s"
          console.log "Item #{finalResults_i + 1} ", @get('videoUrl') + timeInSec + "s"
          @set 'detailedTime', @get('videoUrl') + timeInSec + "s"
        @incrementProperty('finalResults_i',1)
        _frIndex++
      currentIndex++
    return finalResults

  getNextElement: (elements, i) ->
    elements[i]

  isAction: (element) ->
    if @get('bbActions').indexOf(element) > -1
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
    beforeType = ['make','miss','grab','shoot','take','lose']
    afterType = ['turnover-on','foul-on','foul-by','no-basket-for','steal-for']
    bothType = ['pass','inbound','bounce']
    if beforeType.indexOf(element) > -1
      return "before"
    else if afterType.indexOf(element) > -1
      "after"
    else if bothType.indexOf(element) > -1
      "both"

  getContext: (arr,ID_i, current_i,type, action) ->
    context = []
    contextComplete = false
    if type == "before"
      playerID = arr[ID_i]
      context.push(playerID)
      @addActionToPlayer(playerID, action)
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
          @addActionToPlayer(playerID, action)
          @set('lastID_i', current_i)
          currentIndex = current_i
          contextComplete = true
        else if (@isAction(arr[current_i]))
          currentIndex = current_i
          contextComplete = true
    else if (type == "both")
      playerID = arr[ID_i]
      context.push(playerID)
      @addActionToPlayer(playerID, action)
      while (!contextComplete)
        context.push(arr[current_i++])
        if (typeof (arr[current_i]) == 'undefined')
          currentIndex = current_i - 1
          contextComplete = true
          break
        if (@isID(arr[current_i]))
          context.push(arr[current_i])
          @set('lastID_i', current_i)
          currentIndex = current_i
          contextComplete = true
    return context

  addActionToPlayer: (playerID, action) ->
    for id,i in @get('playerIDs')
      if Em.isEqual(id,playerID)
        @get('playersData')[i].push(action)

  replaceAll: (find, replace, str) ->
    return str.replace(new RegExp(find, 'g'), replace)

  isNumber: (n) ->
    return !isNaN(parseFloat(n)) && isFinite(n)

  actions:
    startListening: ->
      recognition = @get('recognition')
      status = @get('isListening')
      @toggleProperty('isListening')

      if !status
        recognition.start()
        now = moment()
        @set 'startTime', now
      else
        recognition.stop()
        now = moment()
        @set 'endTime', now

    goToCalibrate: ->
      @transitionToRoute('calibration')

    grabLink: (val) ->
      result = val
        .toString()
        .split(',')
        .toArray()[0]
        .toLowerCase()
        .replace("item ","")
      index = result - 1


      window.open(@get('linksArray')[index])

`export default SplashController`
