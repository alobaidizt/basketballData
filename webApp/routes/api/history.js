var mongoose = require('mongoose');  
var History = require('../../models/history');
var map = require('arr-map');

module.exports.addRecord = function(req, res) {  
    var history = new History(req.body.history);
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
        res.json({history: historyRecords});
    });
};
