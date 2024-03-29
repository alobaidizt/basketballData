Keyword = require('../../models/keyword')
co      = require("bluebird").coroutine

getAllKeywords = co (req) ->
  yield Keyword.find()

updateKeywordByName = co (name, mask) ->
  #TODO make sure it doesn't add exising words
  yield Keyword.findOneAndUpdate({ name: name }, { name: name, $push: { masks: mask } }, { new: true, upsert: true})

module.exports =
  getAllKeywords:      getAllKeywords
  updateKeywordByName: updateKeywordByName
