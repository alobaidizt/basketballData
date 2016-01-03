`import Ember from "ember"`

Filters = Ember.Mixin.create

  filter: (results) ->
    @set('detectedActions', [])

    f1r = @firstFilter(results)
    f2r = @secondFilter(f1r,'filter')
    f3r = @thirdFilter(f2r)
    #f4r = @getText(f3r)
    #console.log 'players Data: ', @get('playersData')
    #console.log 'playerIDs: ', @get('playerIDs')
    @get('structuredData').pushObjects(f3r)
    @setProperties
      resultString: f1r
      showResult:   true
    @set 'timestamps', []

    record =
      timestamp:          moment().unix()
      beforeEnhancement:  f1r
      afterEnhancement:   @get('afterEnhancement')
      structuredOutput:   @get('structuredOutput')

    @get('api').addHistoryRecord(record).then ->
      console.log('recorded')

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
    @set('afterEnhancement', f1r)
    
    parsedResults = f1r.split(" ")

    if purpose == 'filter'
      output = @get('output')
    else if purpose == 'timestamp'
      output = @get('outputTS')

    for parsedResult,i in parsedResults
      if parsedResult.toString().includes('number')
        output.push(parsedResult)
      if parsedResult.toString().includes('1st')
        output.push(parsedResult)
      if parsedResult.toString().includes('2nd')
        output.push(parsedResult)
      if parsedResult.toString().includes('rebound')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('rebound')
      else if parsedResult.toString().includes('rebound-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('rebound-for')
      if parsedResult.toString().includes('inbound')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('inbound')
      if parsedResult.toString().includes('bounce')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('bounce')
      if parsedResult.toString().includes('make')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('make')
      if parsedResult.toString().includes('assist')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('assist')
      if parsedResult.toString().includes('take')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('take')
      if parsedResult.toString().includes('miss')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('miss')
      if parsedResult.toString().includes('grab')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('grab')
      if parsedResult.toString().includes('lose')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('lose')
      if parsedResult.toString().includes('pass')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('pass')
      if parsedResult.toString().includes('shoot')
        parsedResults.splice(i,1,'attempt') # find a way to put this before shoot
        output.push(parsedResult,'attempt')
        if purpose == 'filter'
          @_addNotification('shoot')
          @_addNotification('attempt')
      if parsedResult.toString().includes('score')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('score')
      if parsedResult.toString().includes('turnover-on')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('turnover-on')
      else if parsedResult.toString().includes('turnover-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('turnover-for')
      else if parsedResult.toString().includes('turnover')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('turnover')
      if parsedResult.toString().includes('free-throw')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('free-throw')
      if parsedResult.toString().includes('no-basket-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('no-basket-for')
      if parsedResult.toString().includes('foul-by')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('foul-by')
      if parsedResult.toString().includes('layup')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('layup')
      if parsedResult.toString().includes('foul-on')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('foul-on')
      if parsedResult.toString().includes('ball-to')
        output.push(parsedResult)
      if parsedResult.toString().includes('ball-from')
        output.push(parsedResult)
      if parsedResult.toString().includes('steal-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @_addNotification('steal-for')
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

    while currentIndex <= (f2r.length - 1)
      currentElement = @getNextElement(f2r, currentIndex)
      if @isID(currentElement)
        @set('lastID', currentElement)
        currentIndex++
        currentElement = @getNextElement(f2r, currentIndex)
      if @isAction(currentElement)
        action = currentElement
        @get('detectedActions').pushObject(action)
        type = @getActionParamsType(currentElement)
        actionTS = @getActionTS(currentElement)
        timeStamp = if actionTS? then actionTS else "-"
        finalResults[_frIndex] = @getContext(f2r, @get('lastID'),currentIndex, type, action)
        finalResults[_frIndex].unshift("Item #{finalResults_i + 1}", timeStamp)
        if actionTS?
          timeInSec = actionTS - 2
          @get('linksArray')[finalResults_i] = @get('videoUrl') + "#t=" + timeInSec + "s"
          console.log "Item #{finalResults_i + 1} ", @get('videoUrl') + timeInSec + "s"
          @set 'detailedTime', @get('videoUrl') + timeInSec + "s"
        @incrementProperty('finalResults_i',1)
        _frIndex++
      currentIndex++
      @set('structuredOutput', finalResults)
    return finalResults

`export default Filters`
