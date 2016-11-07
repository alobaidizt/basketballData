Promise = require("bluebird")
co      = Promise.coroutine
express = require('express')
router  = express.Router()

keywords  = require('./api/keyword')
histories = require('./api/history')
config    = require('./api/config')
stats     = require('./api/stat')
email     = require('./api/email')

router.route('/keywords')
    .post co (req) -> res.send({ keyword: yield keywords.addKeyword(req) })
    .get co (req, res)  ->
      res.send({ keywords: yield keywords.getAllKeywords(req) })

router.route('/keywords/:keyword_id')
    .get co (req)    -> yield keywords.getSingleKeyword(req, req.params.keyword_id)
    .post co (req)   -> yield keywords.updateKeyword(req, req.params.keyword_id)
    .delete co (req) -> yield keywords.deleteKeyword(req, req.params.keyword_id)
router.route('/keywords/name/:keyword_name')
    .get (req)    -> yield keywords.getKeywordByName(req, req.params.keyword_name)
    .post (req)   -> yield keywords.updateKeywordByName(req, req.params.keyword_name)
    .delete (req) -> yield keywords.deleteKeywordByName(req, req.params.keyword_name)
router.route('/keywords/name/:keyword_name/:mask')
    #.post (req) -> yield keywords.updateKeywordByName(req, req.params.keyword_name)
    .delete (req) -> yield keywords.deleteMask(req, req.params.keyword_name, req.params.mask)

#router.route('/histories')
    #.post (req) -> yield histories.addRecord(req)
    #.get (req)  -> yield histories.getHistoryRecords(req)
#router.route('/histories/:session_id')
    #.get (req)    -> yield histories.getHistoryBySession(req, req.params.session_id)
    #.delete (req) -> yield histories.deleteSessionHistory(req, req.params.session_id)

router.route('/config')
  .delete (req, res) ->
    yield config.deleteConfigs(req)
    res.sendStatus(200)
  .get (req, res) -> res.send({ configs: yield config.deleteConfigs(req) })
router.route('/config/delay')
    .get (req, res)  -> res.send({ delay: yield config.getDelay(req)[0].actionCaptureDelay })
    .post (req, res) -> res.send({ delay: yield config.updateDelay(req) })
router.route('/config/duration')
    .get (req, res)  -> res.send({ duration: yield config.getDuration(req)[0].clipDuration })
    .post (req, res) -> res.send({ duration: yield config.updateDuration(req) })
router.route('/config/stitch')
  .get (req, res)    -> res.send({ stitches: yield config.getStitches(req)[0].stitchesHash })
  .post (req, res)   -> res.send({ stitches: yield config.updateStitches(req) })
  .delete (req, res) ->
    yield config.deleteStitches(req)
    res.sendStatus(200)
router.route('/config/action')
  .get (req, res)    -> res.send({ actions: yield config.getActions(req)[0].detectableActions })
  .post (req, res)   -> res.send({ actions: yield config.updateActions(req) })
  .delete (req, res) ->
    yield config.deleteActions(req)
    res.sendStatus(200)

router.route('/stats')
  .post (req, res) -> res.send({ stats: yield stats.postStats(req) })
  .get (req, res)  -> res.send({ stats: yield stats.getStats(req) })

router.route('/emails')
  .post (req) -> yield email.postEmail(req)

module.exports = router
