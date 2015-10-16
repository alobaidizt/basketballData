`import Ember from 'ember'`
`import moment from 'moment'`

SplashController = Ember.Controller.extend
  showScript:	      false
  isListening:      false
  showResult:       false
  detectedActions:  []
  playerIDs:        []
  playersData:      []
  recognition:      undefined
  currentIndex:	    undefined
  lastID:           undefined
  lastID_i:   	    undefined
  currentElement:   undefined
  structuredData:   undefined
  startTime:        undefined
  endTime:          undefined
  tsPointer:        null       # Timestamp pointer

  showTable: Ember.computed 'structuredData', ->
    Ember.isPresent @get('structuredData')

  duration: Em.computed 'startTime', 'endTime', ->
    @get('endTime').diff(@get('startTime'), 'seconds')

  init: ->
    @_super()

    #For Testing purposes
     
    #data = [
      #['Item 1','-','#24-blue','pass','ball-to','#10-blue']
      #['Item 2','23567681','#3-red','make','2']
    #]
    #actions = ['make','shoot','rebound']
    #resultTxt = 'Lorem ipsum dolor sit amet, eu has graece adolescens efficiendi'
    #@set('structuredData', data)
    #@set('detectedActions', actions)
    #@set('resultString', resultTxt)

    recognition = new webkitSpeechRecognition()

    recognition.maxAlternatives = 10
    recognition.continuous      = true
    recognition.interimResults  = true

    keywords = ['shoot', 'make', 'inbound','bounce', 'lose', 'steal', 'pass', 'foul', 'free throw', 'miss', 'rebound', 'turnover', 'blue', 'red']
    bbActions = ['make','miss','grab','pass','lose','shoot','turnover-on','take','foul-by','foul-on','no-basket-for','steal-for','inbound','bounce']
    
    # Adding Speech Grammar
    for word in keywords
      recognition.grammars.addFromString(word)
    for word in bbActions
      recognition.grammars.addFromString(word)


    output = new Array()
    outputTS = new Array()
    timestamps = new Array()
    replacements = [['number ', '#', ],['makes','make'],['first','1st'],['second','2nd'],['free throw','free-throw'],['message','misses'],['mrs.','miss'],['misses','miss'],['crabs','grab'],['grabs','grab'],['passes','pass'],['passed','pass'],['shirts','shoots'],['shoots','shoot'],['bounces','bounce'],['inbounds','inbound'],['loses','lose'],['ride','red'],['read','red'],[' red','-red'],['lou', 'blue'],[' blue','-blue'],['turn over','turnover'],['turnover on','turnover-on'],['ii','2nd'],['takes','take'],['follow on', 'foul on'],['follow by', 'foul by'],['filed by', 'followed by'],['followed by', 'fouled by'],['fouled','foul'],['foul by','foul-by'],['foul on','foul-on'],['no basket for','no-basket-for'],['ball to','ball-to'],['ball from','ball-from'],['steel','steal'],['steal for','steal-for'],['the tree', 'three'],['three','3'],['one','1'],['two','2']]


    @setProperties
      recognition:  recognition
      keywords:     keywords
      bbActions:      bbActions
      output:       output
      output:       outputTS
      replacements: replacements
      timestamps:   timestamps


    window.privateVar = this

    recognition.onresult = ((event) =>
      that = window.privateVar
      interimText = ""
      @set 'outputTS', []
      @set 'output', []

      resultArray= new Array()
      if (event.results.length > 0)
        ri = event.resultIndex
        for rr,h in event.results
          if h >= ri
            if event.results[h].isFinal
              @set 'tsPointer', null
              for result,i in event.results[h]
                text = result.transcript
                resultArray[i] = text
            else
              interimText += event.results[h][0].transcript
              #console.log interimText
        #console.log interimText
        @recordTS(interimText) if interimText != ''  # Record Timestamps

        @filter(resultArray) if Em.isPresent(resultArray)
    )
    recognition.onstart = ->
    recognition.onstop  = ->
    recognition.onend   = ->
      that = window.privateVar
      that.toggleProperty('isListening')


    Ember.run.scheduleOnce('afterRender', this, () ->
      $('.dropdown-button').dropdown(
        inDuration: 300
        outDuration: 225
        constrain_width: true
        hover: false
        gutter: 0
        belowOrigin: true
     ))


  recordTS: (text) ->
    @secondFilter(text,'timestamp')
    f2 = @get('outputTS')

    #console.log @get('tsPointer')
    if @get('tsPointer')?
      f2 = f2.slice(@get('tsPointer') + 1)

    for word,i in f2
      if @isAction(word)
        @set('tsPointer', i)
        #timestamp = moment().diff(@get('startTime'), 'seconds')
        timestamp = moment().format()
        @get('timestamps').push([word,timestamp])



  filter: (results) ->

    @set('detectedActions', [])

    f1r = @firstFilter(results)

    f2r = @secondFilter(f1r,'filter')

    f3r = @thirdFilter(f2r)
    console.log 'players Data: ', @get('playersData')
    console.log 'playerIDs: ', @get('playerIDs')

    f4r = @logic(f3r)

    @set('structuredData', f3r)

    @setProperties
      resultString: f1r
      showResult:   true
    @set 'timestamps', []

  logic: (structData) ->
    console.log structData
    for arr in structData
      timestamp = arr[1]
      playerID = arr[2]
      if playerID?.indexOf('#') < 0
        playerID = arr[arr.length - 1]
      dataOut = arr.slice(2).join()
      console.log dataOut

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
    scores = new Array()
    for result,i in results
      for keyword in @get('keywords')
        regexStr = new RegExp(keyword,"g")
        count = (result?.toLowerCase().match(regexStr) || []).length
        if (typeof scores[i] == 'undefined')
          scores[i] = 0
        scores[i] += count

    matchedIndex = scores.indexOf(Math.max.apply(Math,scores))
    return results[matchedIndex].toLowerCase()

  secondFilter: (f1r, purpose) ->
    for replacement in @get('replacements')
      if (f1r.indexOf(replacement[0]) > -1)
        f1r = @replaceAll(replacement[0],replacement[1],f1r)
        #console.log f1r

    parsedResults = f1r.split(" ")

    if purpose == 'filter'
      output = @get('output')
    else if purpose == 'timestamp'
      output = @get('outputTS')

    for parsedResult in parsedResults
      if parsedResult.toString().includes('#')
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
    finalResults_i = 0
    @set('currentIndex', 0)
    finalResults = new Array()
    currentIndex = @get('currentIndex')
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
        link = "https://www.youtube.com/watch?v=KoFNYWVBRL8#t="
        timeStamp = if actionTS? then actionTS else "-"
        #console.log(currentElement)
        #console.log(type)
        finalResults[finalResults_i] = @getContext(f2r, @get('lastID_i'),currentIndex, type, action)
        finalResults[finalResults_i].unshift("Item #{finalResults_i + 1}", timeStamp)
        if actionTS?
          timeInSec = moment(actionTS).diff(@startTime, "seconds")
          console.log "Item #{finalResults_i + 1} ", link + timeInSec + "s"
        #console.log(finalResults_i)
        finalResults_i++
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
    if element.indexOf('#') > -1
      #console.log (element)
      if !(@get('playerIDs').indexOf(element) > -1)
        @get('playerIDs').push(element)
        @get('playersData').push([element])
        #console.log @get('playerIDs')
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
          #console.log typeof(arr[current_i])
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
          #console.log(typeof (arr[current_i]))
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
          #console.log(typeof (arr[current_i]))
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
    scriptClick: ->
      @toggleProperty('showScript')
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
        #console.log @get('duration')

    goToCalibrate: ->
      console.log "hellllo"
      @transitionToRoute('calibration')

`export default SplashController`
