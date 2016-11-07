mongoose = require('mongoose')
History  = require('../../models/history')
Promise  = require("bluebird")
co       = Promise.coroutine
map      = require('arr-map')

module.exports.addRecord = (req) ->
  structuredOutput = []
  record = req.body
  #for (i = 0 i < record.structuredOutputSize i++)
    #structuredOutput.push(record["structuredOutput[" + i + "][]"])

  history = new History
    sessionId:         record.sessionId
    timestamp:         parseInt(record.timestamp)
    beforeEnhancement: record.beforeEnhancement
    afterEnhancement:  record.afterEnhancement
    #structuredOutput:  structuredOutput

  history.save()

module.exports.getHistoryRecords = (req) ->
  History.find()

module.exports.getHistoryBySession = (req, id) ->
  History.find({ sessionId: id })

module.exports.deleteSessionHistory = (req, id) ->
  Keyword.remove({ sessionId: id })
