Promise   = require("bluebird")
co        = Promise.coroutine
express   = require('express')
router    = express.Router()

keywords  = require('./api/keyword')
histories = require('./api/history')
config    = require('./api/config')
stats     = require('./api/stat')
email     = require('./api/email')

router.route('/keywords')
    .get co (req, res)  ->
      res.send({ keywords: yield keywords.getAllKeywords(req) })

router.route('/keywords/name/:keyword_name')
    .post co (req, res) ->
      name = req.params.keyword_name
      mask = req.body.mask.toLowerCase()
      yield keywords.updateKeywordByName(name, mask)
      res.sendStatus(200)

router.route('/histories')
  .post co (req, res) ->
    data = req.body
    yield histories.addRecord(data)
    res.sendStatus(200)

router.route('/config')
  .delete co (req, res) ->
    yield config.deleteConfigs(req)
    res.sendStatus(200)
  .post co (req, res) ->
    res.send({ configs: yield config.updateConfigs(req) })
  .get co (req, res) ->
    res.send({ config: yield config.getConfigs(req) })

router.route('/stats')
  .post co (req, res) ->
    data = req.body
    res.send({ stats: yield stats.postStats(data) })
  .get co (req, res)  ->
    sessionName = req.query.session
    res.send({ stats: yield stats.getStats(sessionName) })

router.route('/stats/total')
  .get co (req, res)  ->
    sessionName = req.query.session
    console.log sessionName
    res.send({ stats: yield stats.getTotals(sessionName) })

router.route('/emails')
  .post co (req, res) ->
    emailAddress = req.body.email
    yield email.postEmail(emailAddress)
    res.sendStatus(200)

module.exports = router
