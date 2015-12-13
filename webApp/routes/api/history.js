var mongoose = require('mongoose');  
var History = require('../../models/history');
var map = require('arr-map');

module.exports.addRecord = function(req, res) {  
    var record = req.body.history;
    var history = new History({
      beforeEnhancement: record.beforeEnhancement,
      afterEnhancement:  record.afterEnhancement,
      structuredOutput:  record.structuredOutput
    });
    console.log(req.body.history);
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
