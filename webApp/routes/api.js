var express = require('express');  
var router = express.Router();

var keywords  = require('./api/keyword');
var history   = require('./api/history');

/* Keywords routes */
router.route('/keywords')  
    .post(function(req,res) { keywords.addKeyword(req,res) })
    .get(function(req,res) { keywords.getAllKeywords(req,res) });

/* Single keyword routes */
router.route('/keywords/:keyword_id')  
    .get(function(req, res) { keywords.getSingleKeyword(req, res, req.params.keyword_id) })
    .put(function(req, res) { keywords.updateKeyword(req, res, req.params.keyword_id) })
    .delete(function(req, res) { keywords.deleteKeyword(req, res, req.params.keyword_id) });

router.route('/keywords/name/:keyword_name')  
    .get(function(req, res) { keywords.getKeywordByName(req, res, req.params.keyword_name) })
    .put(function(req, res) { keywords.updateKeywordByName(req, res, req.params.keyword_name) })
    .delete(function(req, res) { keywords.deleteKeywordByName(req, res, req.params.keyword_name) });

/* History routes */
router.route('/history')  
    .post(function(req,res) { history.addRecord(req,res) })
    .get(function(req,res) { keywords.getHistoryRecords(req,res) });

module.exports = router;  
