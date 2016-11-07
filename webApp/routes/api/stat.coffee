Stat     = require('../../models/stat')
map      = require('arr-map')
io    = require('../../websocket')
Promise  = require("bluebird")
co       = Promise.coroutine

getStats = (req) ->
  session = req.query.session
  Stat
    .find({ sessionName: session })
    .sort('playerNumber')
    .exec()

postStats = co (req) ->
  query = req.body

  videoRef  = query['stat[videoRef]']
  session   = query['stat[sessionId]']
  action    = query['stat[action]']
  subject   = query['stat[subject]']
  timestamp = parseInt(query['stat[timestamp]'])

  if isNaN(subject)
    return new Error("no subject was found")
  if subject.length > 2
    return new Error("subject number has more than 2 digits")
  if action == null
    return new Error("no action was found")

  incrementHash                    = {}
  pushLinkHash                     = {}
  incrementHash["#{action}.count"] = 1
  pushLinkHash["#{action}.stamps"] = timestamp
  timestampLowerBound              = timestamp - 5

  queryHash = {}
  queryHash["sessionName"] = session
  queryHash["videoPath"] = videoRef
  queryHash["playerNumber"] = subject
  findQueryHash = {}
  findQueryHash["sessionName"] = session
  findQueryHash["videoPath"] = videoRef
  findQueryHash["playerNumber"] = subject
  findQueryHash["#{action}.stamps"] =
    $not:
      $elemMatch:
        $gte: timestampLowerBound
        $lte: timestamp



  yield Stat.update(
    queryHash
    ,
    $set: queryHash
    ,
    new: true
    upsert: true
    setDefaultsOnInsert: true
  )

  stats = yield Stat.update(
    findQueryHash
    ,
    $inc: incrementHash
    $push: pushLinkHash
    ,
    new: true
  )


  if (stats.nModified > 0)
    yield Stat.update(
      playerNumber: "99999"
      sessionName: session
      ,
      $set:
        playerNumber: "99999"
        sessionName: session
      ,
      upsert: true
      new: true
      setDefaultsOnInsert: true
    )

    yield Stat.update(
      playerNumber: "99999"
      sessionName: session
      ,
      $inc: incrementHash
      $push: pushLinkHash
    )

  io.emit('update', {session: session})

module.exports =
  getStats: (req) -> getStats(req)
  postStats: (req) -> postStats(req)
