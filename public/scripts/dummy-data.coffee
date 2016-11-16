# this was in commentator controller. Modify to send dummy data
    addDummyData: ->
      num = @getRandomIntInclusive(5,15)
      stat =
        videoRef:     @get('videoUrl')
        sessionId:    @get('sessionId')
        timestamp:    parseInt(null ? @get('delay')) - @get('delay')
        actionType:   "after"
        action:       "steal"
        subject:      "number-#{num}"
        localContext: ['test']

      @get('api').addStat({stat: stat}).then ->
        console.log('add a stat')

    testData: ->
      #assist in the middle test case = "number 12 pass to number 3, number-3 attempt a three-points shot and makes a three-points shot in number-23 steal the ball"
      sentence = "number 12 pass to number 3, number-3 attempt a three-points shot and makes a three-points shot in number-23 steal the ball"
      @set('outputTS', [10])
      @set('output', [])
      @filter([sentence])

