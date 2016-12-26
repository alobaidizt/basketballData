Stat            = require('../../models/stat')
co              = require("bluebird").coroutine
{ getIOServer } = require('../../websocket')

io = getIOServer()

getStats = co (sessionName) ->
  yield Stat
    .find(sessionName: sessionName)
    .sort('playerNumber')
    .exec()

postStats = co (data) ->
  videoRef  = data['stat[videoRef]']
  session   = data['stat[sessionId]']
  action    = data['stat[action]']
  subject   = data['stat[subject]']
  timestamp = parseInt(data['stat[timestamp]'])

  queryHash =
    sessionName:  session
    videoPath:    videoRef
    playerNumber: subject

  yield Stat.update(queryHash, { $set: queryHash }, { new: true, upsert: true })

  findQueryHash =
    sessionName:  session
    videoPath:    videoRef
    playerNumber: subject
    #"#{action}.stamps":
      #$not:
        #$elemMatch:
          #$gte: timestamp - 5
          #$lte: timestamp

  incrementHash =
    "#{action}.count": 1
  pushLinkHash =
    "#{action}.stamps": timestamp

  stats = yield Stat.update(findQueryHash, { $inc: incrementHash, $push: pushLinkHash }, { new: true })

  io.emit 'update',
    session: session

  stats

getTotals = co (sessionName) ->
  aggregate = Stat.aggregate()
  aggregate
    .match
      sessionName: sessionName
    .project
      "twoPointAttempt.player": $map:
        input: "$twoPointAttempt.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$twoPointAttempt.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "twoPointMade.player": $map:
        input: "$twoPointMade.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$twoPointMade.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "threePointAttempt.player": $map:
        input: "$threePointAttempt.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$threePointAttempt.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "threePointMade.player": $map:
        input: "$threePointMade.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$threePointMade.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "freeThrowAttempt.player": $map:
        input: "$freeThrowAttempt.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$freeThrowAttempt.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "freeThrowMade.player": $map:
        input: "$freeThrowMade.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$freeThrowMade.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "assist.player": $map:
        input: "$assist.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$assist.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "foul.player": $map:
        input: "$foul.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$foul.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "rebound.player": $map:
        input: "$rebound.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$rebound.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "turnover.player": $map:
        input: "$turnover.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$turnover.stamps", 1 ] }, "$playerNumber", "$haox" ]
      "steal.player": $map:
        input: "$steal.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$steal.stamps", 1 ] }, "$playerNumber", "$haox" ]
      data: "$$ROOT"
      "twoPointAttempt.player": $map:
        input: "$twoPointAttempt.stamps"
        as: "stamp"
        in: $cond: [ { $gte: [ "$twoPointAttempt.stamps", 1 ] }, "$playerNumber", "$haox" ]

    .group
      _id:                     "$data.sessionName"
      sessionName:             $last: "$data.sessionName"
      videoPath:               $last: "$data.videoPath"
      twoPointAttemptCount:    $sum: "$data.twoPointAttempt.count"
      twoPointAttemptStamps:   $addToSet: "$data.twoPointAttempt.stamps"
      twoPointAttemptPlayer:   $addToSet: $ifNull: [ "$twoPointAttempt.player", "$hoax"]
      twoPointMadeCount:       $sum: "$data.twoPointMade.count"
      twoPointMadeStamps:      $addToSet: "$data.twoPointMade.stamps"
      twoPointMadePlayer:      $addToSet: $ifNull: [ "$threePointMade.player", "$hoax"]
      threePointAttemptCount:  $sum: "$data.threePointAttempt.count"
      threePointAttemptStamps: $addToSet: "$data.threePointAttempt.stamps"
      threePointAttemptPlayer: $addToSet: $ifNull: [ "$threePointAttempt.player", "$hoax"]
      threePointMadeCount:     $sum: "$data.threePointMade.count"
      threePointMadeStamps:    $addToSet: "$data.threePointMade.stamps"
      threePointMadePlayer:    $addToSet: $ifNull: [ "$threePointMade.player", "$hoax"]
      freeThrowAttemptCount:   $sum: "$data.freeThrowAttempt.count"
      freeThrowAttemptStamps:  $addToSet: "$data.freeThrowAttempt.stamps"
      freeThrowAttemptPlayer:  $addToSet: $ifNull: [ "$freeThrowAttempt.player", "$hoax"]
      freeThrowMadeCount:      $sum: "$data.freeThrowMade.count"
      freeThrowMadeStamps:     $addToSet: "$data.freeThrowMade.stamps"
      freeThrowMadePlayer:     $addToSet: $ifNull: [ "$freeThrowMade.player", "$hoax"]
      assistCount:             $sum: "$data.assist.count"
      assistStamps:            $addToSet: "$data.assist.stamps"
      assistPlayer:            $addToSet: $ifNull: [ "$assist.player", "$hoax"]
      foulCount:               $sum: "$data.foul.count"
      foulStamps:              $addToSet: "$data.foul.stamps"
      foulPlayer:              $addToSet: $ifNull: [ "$foul.player", "$hoax"]
      reboundCount:            $sum: "$data.rebound.count"
      reboundStamps:           $addToSet: "$data.rebound.stamps"
      reboundPlayer:           $addToSet: $ifNull: [ "$rebound.player", "$hoax"]
      turnoverCount:           $sum: "$data.turnover.count"
      turnoverStamps:          $addToSet: "$data.turnover.stamps"
      turnoverPlayer:          $addToSet: $ifNull: [ "$turnover.player", "$hoax"]
      stealCount:              $sum: "$data.steal.count"
      stealStamps:             $addToSet: "$data.steal.stamps"
      stealPlayer:             $addToSet: $ifNull: [ "$steal.player", "$hoax"]
    .project
      _id: 1
      sessionName: "$sessionName"
      videoPath: "$videoPath"
      playerNumber: $literal: "Total"
      twoPointAttempt:
        count: "$twoPointAttemptCount"
        stamps: "$twoPointAttemptStamps"
        players: "$twoPointAttemptPlayer"
      twoPointMade:
        count: "$twoPointMadeCount"
        stamps: "$twoPointMadeStamps"
        players: "$twoPointMadePlayer"
      threePointAttempt:
        count: "$threePointAttemptCount"
        stamps: "$threePointAttemptStamps"
        players: "$threePointAttemptPlayer"
      threePointMade:
        count: "$threePointMadeCount"
        stamps: "$threePointMadeStamps"
        players: "$threePointMadePlayer"
      freeThrowAttempt:
        count: "$freeThrowAttemptCount"
        stamps: "$freeThrowAttemptStamps"
        players: "$freeThrowAttemptPlayer"
      freeThrowMade:
        count: "$freeThrowMadeCount"
        stamps: "$freeThrowMadeStamps"
        players: "$freeThrowMadePlayer"
      assist:
        count: "$assistCount"
        stamps: "$assistStamps"
        players: "$assistPlayer"
      foul:
        count: "$foulCount"
        stamps: "$foulStamps"
        players: "$foulPlayer"
      rebound:
        count: "$reboundCount"
        stamps: "$reboundStamps"
        players: "$reboundPlayer"
      turnover:
        count: "$turnoverCount"
        stamps: "$turnoverStamps"
        players: "$turnoverPlayer"
      steal:
        count: "$stealCount"
        stamps: "$stealStamps"
        players: "$stealPlayer"

  yield aggregate.exec()

module.exports =
  getStats:  getStats
  postStats: postStats
  getTotals: getTotals
