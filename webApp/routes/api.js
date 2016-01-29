var express = require('express');  
var router = express.Router();

var keywords  = require('./api/keyword');
var histories = require('./api/history');
var configs = require('./api/config');

/* Keywords routes */
router.route('/keywords')  
    .post(function(req,res) { keywords.addKeyword(req,res); })
    .get(function(req,res) { keywords.getAllKeywords(req,res); });

/* Single keyword routes */
router.route('/keywords/:keyword_id')  
    .get(function(req, res) { keywords.getSingleKeyword(req, res, req.params.keyword_id); })
    .put(function(req, res) { keywords.updateKeyword(req, res, req.params.keyword_id); })
    .delete(function(req, res) { keywords.deleteKeyword(req, res, req.params.keyword_id); });

router.route('/keywords/name/:keyword_name')  
    .get(function(req, res) { keywords.getKeywordByName(req, res, req.params.keyword_name); })
    .put(function(req, res) { keywords.updateKeywordByName(req, res, req.params.keyword_name); })
    .delete(function(req, res) { keywords.deleteKeywordByName(req, res, req.params.keyword_name); });

/* History routes */
router.route('/histories')  
    .post(function(req,res) { histories.addRecord(req,res); })
    .get(function(req,res) { histories.getHistoryRecords(req,res); });

/* Config routes */
router.route('/config')  
    .delete(function(req, res) { configs.deleteConfigs(req, res); });
router.route('/config/delay')  
    .get(function(req,res) { configs.getDelay(req,res); })
    .put(function(req,res) { configs.updateDelay(req,res); });
router.route('/config/stitch')  
    .get(function(req,res) { configs.getStitches(req,res); })
    .put(function(req,res) { configs.updateStitches(req,res); })
    .delete(function(req, res) { configs.deleteStitches(req, res); });
router.route('/config/action')  
    .get(function(req,res) { configs.getActions(req,res); })
    .put(function(req,res) { configs.updateActions(req,res); })
    .delete(function(req, res) { configs.deleteActions(req, res); });

module.exports = router;  
