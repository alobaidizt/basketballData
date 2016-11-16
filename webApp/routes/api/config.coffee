Config = require('../../models/config')
co     = require("bluebird").coroutine

getConfigs = co (req) ->
  yield Config.findOne()

updateConfigs = co (req) ->
  yield Config.update(req.body)

deleteConfigs = co (req) ->
  yield Config.remove()

module.exports =
  getConfigs:    getConfigs
  updateConfigs: updateConfigs
  deleteConfigs: deleteConfigs
