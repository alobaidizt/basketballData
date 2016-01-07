`import Ember from 'ember'`
`import moment from 'moment'`
`import LogicMixin from 'insight-sports/mixins/logic'`
`import FiltersMixin from 'insight-sports/mixins/filters'`

SplashController = Ember.Controller.extend LogicMixin, FiltersMixin,

  api:              Ember.inject.service()
  recognition:      Ember.inject.service()

  showScript:	      false
  isListening:      false
  showResult:       false
  detectedActions:  []
  playerIDs:        []
  playersData:      []
  keywords:         []
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

  showTable:        true

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
      maxAlternatives: 4
      continuous: true
      interimResults: true

    rec = @get('recognition').createRecognizer(config)
    @set('_recognition', rec)

    # TODO: add bbActions to the DB
    bbActions = ['make','miss','grab','pass','lose','shoot','attempt','score','turnover-on','turnover-for','turnover','take','foul-by','foul-on','no-basket-for','steal-for','inbound','bounce','layup','rebound','assist']
    
    # TODO: remove this
    @get('api').getAllKeywords().then ({keywords}) =>
      keywords.forEach (keyword) =>
        @get('keywords').pushObject(keyword.name)
        @get('replacements').pushObject([keyword.name,keyword.masks])

    # Adding Speech Grammar
    for word in @get('keywords')
      @get('_recognition').grammars.addFromString(word)

    # Stiching
    # TODO: add stitches to the DB
    stitches = [['number ','number-'],[' red','-red'],[' blue','-blue'],['turnover on','turnover-on'],['turnover for','turnover-for'],['foul by','foul-by'],['foul on','foul-on'],['no basket for','no-basket-for'],['ball to','ball-to'],['ball from','ball-from'],['steal for','steal-for'],['layup for','layup-for'],['rebound for','rebound-for']]


    @setProperties
      bbActions:      bbActions
      stitches:       stitches
      finalResults_i: 0 # used in filter 3
      videoUrl:       "https://www.youtube.com/watch?v=OY3lSTb_DM0"

    @get('_recognition').onresult = ((event) =>
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
    @get('_recognition').onstart = ->
    @get('_recognition').onstop  = ->
    @get('_recognition').onend   = =>
      @get('_recognition').start() if Em.isEqual(@get('isListening'), true)

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

  _addNotification: (word) ->
    @notifications.addNotification
      message: "#{word}"
      type: 'info'
      autoClear: true
      clearDuration: 750

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
    beforeType = ['make','attempt','miss','grab','shoot','attempt','score','take','lose','layup','rebound','turnover','assist']
    afterType = ['turnover-on','turnover-for','foul-on','foul-by','no-basket-for','steal-for','layup-for','rebound-for']
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
        @addActionToPlayer(lastPlayer, action)
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
          @set('lastID', playerID)
          currentIndex = current_i
          contextComplete = true
        else if (@isAction(arr[current_i]))
          currentIndex = current_i
          contextComplete = true
    else if (type == "both")
      context.push(lastPlayer)
      @set('assistingPlayer', lastPlayer) if Em.isEqual(action,'pass')
      @addActionToPlayer(lastPlayer, action)
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
      recognition = @get('_recognition')
      status = @get('isListening')
      @toggleProperty('isListening')

      if !status
        window.emberYouTubePlayer.playVideo()
        recognition.start()
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
