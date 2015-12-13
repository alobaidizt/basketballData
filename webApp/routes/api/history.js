var mongoose = require('mongoose');  
var History = require('../../models/history');
var map = require('arr-map');

module.exports.addRecord = function(req, res) {  
    var structuredOutput = [];
    var record = req.body;
    for (var i = 0; i < record.structuredOutputSize; i++) {
      structuredOutput.push(record["structuredOutput[" + i + "][]"]);
    }
    var history = new History({
      beforeEnhancement: record.beforeEnhancement,
      afterEnhancement:  record.afterEnhancement,
      structuredOutput:  structuredOutput
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
