History = require('../../models/history')
co      = require("bluebird").coroutine

addRecord = co (data) ->
  history = new History(data)
  yield history.save(history)

module.exports =
  addRecord: addRecord
