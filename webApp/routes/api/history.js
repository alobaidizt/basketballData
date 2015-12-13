var mongoose = require('mongoose');  
var History = require('../../models/history');
var map = require('arr-map');

module.exports.addRecord = function(req, res) {  
    console.log(req.body.beforeEnhancement);
    var record = req.body;
    var history = new History({
      beforeEnhancement: record.beforeEnhancement,
      afterEnhancement:  record.afterEnhancement,
      structuredOutput:  record.structuredOutput
    });
    history.save(function(err) {
        if (err) {
            res.send(err);
        }
        res.json({history: history});
    });
};

module.exports.getHistoryRecords = function(req, res) {  
    History.find(function(err, historyRecords) {
        if (err) {
            res.send(err);
        }
        res.json({historyRecords: historyRecords});
    });
};
