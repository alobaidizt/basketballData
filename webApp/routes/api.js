var express = require('express');  
var router = express.Router();

var keywords  = require('./api/keyword');
var histories = require('./api/history');
var config = require('./api/config');

/* Keywords routes */
router.route('/keywords')
    .post(function(req,res) { keywords.addKeyword(req,res); })
    .get(function(req,res) { keywords.getAllKeywords(req,res); });

/* Single keyword routes */
router.route('/keywords/:keyword_id')
    .get(function(req, res) { keywords.getSingleKeyword(req, res, req.params.keyword_id); })
    .post(function(req, res) { keywords.updateKeyword(req, res, req.params.keyword_id); })
    .delete(function(req, res) { keywords.deleteKeyword(req, res, req.params.keyword_id); });

router.route('/keywords/name/:keyword_name')
    .get(function(req, res) { keywords.getKeywordByName(req, res, req.params.keyword_name); })
    .post(function(req, res) { keywords.updateKeywordByName(req, res, req.params.keyword_name); })
    .delete(function(req, res) { keywords.deleteKeywordByName(req, res, req.params.keyword_name); });

router.route('/keywords/name/:keyword_name/:mask')
    //.post(function(req, res) { keywords.updateKeywordByName(req, res, req.params.keyword_name); })
    .delete(function(req, res) { keywords.deleteMask(req, res, req.params.keyword_name, req.params.mask); });

/* History routes */
router.route('/histories')
    .post(function(req,res) { histories.addRecord(req,res); })
    .get(function(req,res) { histories.getHistoryRecords(req,res); });

router.route('/histories/:session_id')
    .get(function(req, res) { histories.getHistoryBySession(req, res, req.params.session_id); })
    .delete(function(req, res) { histories.deleteSessionHistory(req, res, req.params.session_id); });

/* Config routes */
router.route('/config')
    .delete(function(req, res) { config.deleteConfigs(req, res); });
router.route('/config/delay')
    .get(function(req,res) { config.getDelay(req,res); })
    .post(function(req,res) { config.updateDelay(req,res); });
router.route('/config/stitch')
    .get(function(req,res) { config.getStitches(req,res); })
    .post(function(req,res) { config.updateStitches(req,res); })
    .delete(function(req, res) { config.deleteStitches(req, res); });
router.route('/config/action')
    .get(function(req,res) { config.getActions(req,res); })
    .post(function(req,res) { config.updateActions(req,res); })
    .delete(function(req, res) { config.deleteActions(req, res); });

module.exports = router;  
