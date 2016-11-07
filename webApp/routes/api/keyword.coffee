Keyword  = require('../../models/keyword')
Promise  = require("bluebird")
co       = Promise.coroutine
map      = require('arr-map')

addKeyword = (req) ->
  keyword = new Keyword(req.body.keyword)
  keyword.save()

getAllKeywords = co (req) ->
  console.log 'getting all keywords'
  yield Keyword.find()

getSingleKeyword = (req, id) ->
  Keyword.findById(id)

updateKeyword = (req, id) ->
  Keyword.findByIdAndUpdate(
    id,
    $set: req.body.keyword
  )

deleteKeyword = (req, id) ->
  Keyword.findByIdAndRemove(id)

getKeywordByName = (req, name) ->
  Keyword.findOne(
    name: name
  )

updateKeywordByName = co (req, name) ->
  mask = req.body.mask.toLowerCase()
  # make sure it doesn't add exising words
  Keyword.findOneAndUpdate(
    name: name
    ,
    $push:
      masks: mask
    ,
    upsert: true
  )


deleteKeywordByName = (req, name) ->
  Keyword.findOneAndRemove({ name: name })

deleteMask = (req, name, mask) ->
  Keyword.findOneAndUpdate(
    name: name
    ,
    $pull:
      masks: mask
    ,
    returnNewDocument: true
  )

module.exports =
  addKeyword: (req) -> addKeyword(req)
  getAllKeywords: (req) -> getAllKeywords(req)
  getSingleKeyword:    getSingleKeyword
  deleteKeyword:       deleteKeyword
  updateKeyword:       updateKeyword
  getKeywordByName:    getKeywordByName
  updateKeywordByName: updateKeywordByName
  deleteKeywordByName: deleteKeywordByName
  deleteMask:          deleteMask
