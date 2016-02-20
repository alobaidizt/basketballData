`import Ember from 'ember'`
`import moment from 'moment'`
`import LogicMixin from 'insight-sports/mixins/logic'`
`import FiltersMixin from 'insight-sports/mixins/filters'`

SplashController = Ember.Controller.extend LogicMixin, FiltersMixin,

  api:              Ember.inject.service()
  recognition:      Ember.inject.service()

  showScript:	      false
  showResult:       false
  detectedActions:  []
  playerIDs:        []
  playersData:      []
  replacements:     []
  linksArray:       []
  timestamps:       []
  _recognition:     undefined
  currentIndex:	    undefined
  lastID:           undefined
  lastID_i:   	    undefined
  lastAction:       undefined
  currentElement:   undefined
  structuredData:   []
  startTime:        undefined
  endTime:          undefined
  tsPointer:        null       # Timestamp pointer
  videoUrl:         undefined
  finalResults_i:   undefined
  ytPlayer:         {}
  keywords:         []

  showTable:        true
  isListening:      Ember.computed.alias('recognition.isListening')

  yt_id:     Ember.computed 'videoUrl', ->
    @youTubeGetID(@get('videoUrl'))

  videoIconClass: Ember.computed 'isListening', ->
    if @get('isListening')
      'pause_circle_filled'
    else
      'play_circle_filled'

  init: ->
    @_super()

    config =
      maxAlternatives:   4
      continuous:        true
      interimResults:    true
      lang:              'en-US'

    rec = @get('recognition').createRecognizer(config)
    @get('recognition').bindEvent(rec,'onresult',Em.run.bind(this, @_onResult))
    @set('_recognition', rec)

    # TODO: add bbActions to the DB
    bbActions = ['make','miss','grab','pass','lose','shoot','attempt','score','turnover-on','turnover-for','turnover','take','foul-by','foul-on','foul','no-basket-for','steal-for','inbound','bounce','layup','rebound','rebound-by','rebound-for','assist', 'steal', 'steal-by']

    others = ['rebound-for','rebound-by','turnover-on','turnover-for','no-basket-for','foul-by','foul-on','ball-to','ball-from','steal-for']
    
    # TODO: remove this
    @get('api').getAllKeywords()
      .then ({keywords}) =>
        keywords.forEach (keyword,i) =>
          @get('keywords').pushObject(keyword.name)
          @get('replacements').pushObject([keyword.name,keyword.masks])
      .then =>
        grammerVocab = @get('keywords').concat(others)
        
        # Adding Speech Grammar
        # This is not done, do more research
        #for word in grammerVocab
          #@get('_recognition').grammars.addFromString(word)

    console.log @get('_recognition')

    # Stiching
    # TODO: add stitches to the DB
    stitches = [['number ','number-'],[' red','-red'],[' blue','-blue'],['turnover on','turnover-on'],['turnover for','turnover-for'],['foul by','foul-by'],['foul on','foul-on'],['no basket for','no-basket-for'],['ball to','ball-to'],['ball from','ball-from'],['steal for','steal-for'],['layup for','layup-for'],['rebound for','rebound-for'],['rebound by','rebound-by'],['steal by','steal-by']]


    @setProperties
      bbActions:      bbActions
      stitches:       stitches
      finalResults_i: 0 # used in filter 3
      videoUrl:       "https://www.youtube.com/watch?v=OY3lSTb_DM0"


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
            @get('_recognition').stop()
            @get('_recognition').start()
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
        timestamp = @getVideoCurrentTime()
        @get('timestamps').pushObject([word,timestamp])

  _addNotification: (word, duration = 750) ->
    @notifications.addNotification
      message: "#{word}"
      type: 'info'
      autoClear: true
      clearDuration: duration

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
    beforeType = ['make','attempt','miss','grab','shoot','attempt','score','take','lose','layup','rebound','turnover','assist','foul', 'steal']
    afterType = ['turnover-on','turnover-for','foul-on','foul-by','no-basket-for','steal-for','layup-for','rebound-for','rebound-by', 'steal-for', 'steal-by']
    bothType = ['pass','inbound','bounce']
    if beforeType.indexOf(element) > -1
      return "before"
    else if afterType.indexOf(element) > -1
      "after"
    else if bothType.indexOf(element) > -1
      "both"

  getContext: (arr,lastPlayer, current_i,type, action) ->
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
    return context

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


  youTubeGetID: (url) ->
    # @author: takien
    # @url: http://takien.com
    ID = ''
    url = url.replace(/(>|<)/gi,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/)
    if (url[2] != undefined)
      ID = url[2].split(/[^0-9a-z_\-]/i)
      ID = ID[0]
    else
      ID = url

  getVideoCurrentTime: ->
    window.emberYouTubePlayer.getCurrentTime()

  actions:
    startListening: ->
      if Em.isEmpty(@get('sessionId'))
        @_addNotification("Must enter a session name first", 3000)
        return false
      recognition = @get('_recognition')
      status = @get('isListening')
      @toggleProperty('isListening')

      if !status
        window.emberYouTubePlayer.playVideo()
        @get('_recognition').start()
        now = moment()
        @set 'startTime', now
      else
        data = @get('playersData').sort((a,b) -> b.length - a.length)
        #debugger
        startingNode = document.getElementById('report-summary')
        startingNode.removeChild(startingNode.childNodes[0]) if startingNode.hasChildNodes()
        table = document.createElement('table')
        table.setAttribute('class','centered hoverable table-max-height')
        tableHeader = table.createTHead()
        tableHeader.insertRow(0)
        tableHeader.setAttribute('class','red-text')
        tableBody = document.createElement('tbody')
        tableBody.setAttribute('class','red-text text-lighten-1 data-table')
        for playerStats,i in data
          tableHeader.rows[0].insertCell(i).innerHTML = playerStats[0]
          while tableBody.rows.length < (playerStats.length - 1)
            tableBody.insertRow(tableBody.rows.length)
          for stat,j in playerStats
            if j != 0
              tableBody.rows[j - 1].insertCell(i).innerHTML = stat
        table.appendChild(tableBody)
        startingNode.appendChild(table)

        console.log window.emberYouTubePlayer.getCurrentTime()
        window.emberYouTubePlayer.pauseVideo()
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
