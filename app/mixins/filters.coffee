`import Ember from "ember"`

Filters = Ember.Mixin.create

  filter: (results) ->
    @set('detectedActions', [])

    f1r = @firstFilter(results)
    f2r = @secondFilter(f1r,'filter')
    f3r = @thirdFilter(f2r)

    @get('structuredData').pushObjects(f3r)
    @setProperties
      resultString: f1r
      showResult:   true
    @set 'timestamps', []

    record =
      sessionId:          @get('sessionId')
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
    filteredContent = @_enhanceFourDigNumbers(f1r)
    filteredContent = @_enhanceThreeDigNumbers(filteredContent)
    filteredContent = @_enhanceSentenceBeginnings(filteredContent)
    filteredContent = @_enhanceContentWithReplacementsFromDB(filteredContent)
    filteredContent = @_enhanceContentWithStitchesFromDB(filteredContent)

    # Content after enhancment
    @set('afterEnhancement', filteredContent)
    
    parsedResults = filteredContent.split(" ")

    if purpose == 'filter'
      output = @get('output')
    else if purpose == 'timestamp'
      output = @get('outputTS')

    skip = false
    for parsedResult,i in parsedResults
      if parsedResult.toString() == ""
        continue
      if skip
        skip = false
        continue
      if parsedResult.toString().includes('number')
        output.push(parsedResult)
      if parsedResult.toString().includes('1st')
        output.push(parsedResult)
      if parsedResult.toString().includes('2nd')
        output.push(parsedResult)
      if parsedResult.toString().includes('3rd')
        output.push(parsedResult)
      if parsedResult.toString().includes('rebound')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      else if parsedResult.toString().includes('rebound-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      else if parsedResult.toString().includes('rebound-by')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('inbound')
        output.push("pass")
        if purpose == 'filter'
          @set('lastAction', "pass")
      if parsedResult.toString().includes('bounce')
        output.push("pass")
        if purpose == 'filter'
          @set('lastAction', "pass")

      # business logic for two-points, three-points, & free-throw (implement its own method)
      if parsedResult.toString().includes('make')
        output.push('attempt')
        if purpose == 'filter'
          if Em.isEqual(@get('lastAction'), 'pass')
            output.push('assist')
        output.push("make")
      if parsedResult.toString().includes('score')
        output.push('attempt')
        if purpose == 'filter'
          if Em.isEqual(@get('lastAction'), 'pass')
            output.push('assist')
        output.push("make")
      if parsedResult.toString().includes('attempt')
        output.push('attempt')
      if parsedResult.toString().includes('try')
        output.push('attempt')
      if parsedResult.toString().includes('shoot')
        output.push('attempt')
      if parsedResult.toString().includes('layup')
        output.push('attempt')
      if parsedResult.toString().includes('miss')
        output.push('attempt')
          

      if parsedResult.toString().includes('assist')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('lose')
        output.push('turnover')
        if purpose == 'filter'
          @set('lastAction', 'turnover') # review lastActions when assuming actions like 'turnover' and 'attempt'
      if parsedResult.toString().includes('pass')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('two-points')
        output.push('two-points')
      if parsedResult.toString().includes('three-points')
        output.push('three-points')
      if parsedResult.toString().includes('free-throw')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('turnover-on')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      else if parsedResult.toString().includes('turnover-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      else if parsedResult.toString().includes('turnover')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('foul-by')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('foul-on')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('foul')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('steal')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('steal-for')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if parsedResult.toString().includes('steal-by')
        output.push(parsedResult)
        if purpose == 'filter'
          @set('lastAction', parsedResult.toString())
      if @isNumber(parsedResult.toString())
        output.push(parsedResult)
    return output

  thirdFilter: (f2r) ->
    #TODO: maybe do this in init?
    @set('currentIndex', 0)

    finalResults    = new Array()
    finalResults1    = new Array()
    currentIndex    = @get('currentIndex')
    finalResults_i  = @get('finalResults_i')
    _frIndex = 0

    while currentIndex <= (f2r.length - 1)
      currentElement = @getNextElement(f2r, currentIndex)
      if @isID(currentElement)
        @checkForDuplicates = true
        @set('lastID', currentElement)
        currentIndex++
        currentElement = @getNextElement(f2r, currentIndex)
      if @isAction(currentElement)
        @checkForDuplicates = false
        action = currentElement
        @get('detectedActions').pushObject(action)
        type = @getActionParamsType(currentElement)
        actionTS = @getActionTS(currentElement)
        timeStamp =
          if actionTS?
            actionTS
          else if (action == 'assist')
            @get('lastPassTS')
          else
            "-"
        @setContext(f2r, @get('lastID'),currentIndex, type, action, actionTS)
        @set('notificationMessage',@get('context'))
        finalResults[_frIndex] = @get('context')
        if @possibleDuplicateAction(@get('currentSubject'), action)
          finalResults.splice(_frIndex,1) # remove last entry
          @addNotification('Ignored a duplicate action')
          _frIndex--
        else

          @get('api').addStat({stat: @statObj}).then ->
            console.log('stat added')

          @addNotification(@get('notificationMessage'))
          finalResults[_frIndex].unshift("Item #{finalResults_i + 1}", timeStamp)
          if actionTS?
            timeInSec = parseInt(actionTS) - 2
            @get('linksArray')[finalResults_i] = @get('videoUrl') + "#t=" + timeInSec + "s"
            finalResults[_frIndex].unshift(@get('linksArray')[finalResults_i])
        @setProperties
          previousAction:   action
          previousSubject:  @get('currentSubject')

        @incrementProperty('finalResults_i',1)
        _frIndex++
      currentIndex++
      @set('structuredOutput', finalResults)
    return finalResults.map (row) -> row.slice(1)

  _enhanceFourDigNumbers: (content) ->
    # TODO: refactor this portion
    keepFiltering_4 = true
    while keepFiltering_4
      fourDigNum = content.match(/\d{4}/)?.toString()
      if fourDigNum?
        if fourDigNum.substring(0,2) == fourDigNum.substring(2)
          content = content.replace(fourDigNum, fourDigNum.substring(2))
          keepFiltering_4 = true
        else
          keepFiltering_4 = false
          break
      else
        keepFiltering_4 = false
        break
    content

  _enhanceThreeDigNumbers: (content) ->
    keepFiltering_3 = true
    while keepFiltering_3
      threeDigNum = content.match(/\d{3}/)?.toString()
      if threeDigNum?
        if threeDigNum.substring(0,1) == "2"
          content = content.replace(threeDigNum, threeDigNum.substring(1))
          keepFiltering_3  = true
        else
          keepFiltering_3 = false
          break
      else
        keepFiltering_3 = false
        break
    content

  _enhanceSentenceBeginnings: (content) ->
    if content.match(/^\s*(\d.*)/)?
      return content = "number ".concat(content)
    content

  _enhanceContentWithReplacementsFromDB: (content) ->
    for replacement in @get('replacements')
      for mask in replacement[1]
        if (content.indexOf(mask) > -1) or (mask.indexOf("\\") > -1)
          content = @replaceAll(mask,replacement[0], content)
    content

  _enhanceContentWithStitchesFromDB: (content) ->
    for stitch in @get('stitches')
      key = Object.keys(stitch)[0]
      value = stitch[key]
      if (content.indexOf(key) > -1)
        content = @replaceAll(key,value, content)
    content

`export default Filters`
