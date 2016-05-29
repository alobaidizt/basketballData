var mongoose = require('mongoose');
var Stat     = require('../../models/stat');
var map      = require('arr-map');
var app      = require('../../app');

module.exports.getStats = function(req, res) {  
    var session = req.query.session;
    Stat.find({sessionName: session}, function(err, stats) {
        if (err) {
            res.send(err);
        }
        res.json({stats: stats});
    });
};

module.exports.postStats = function(req, res) {  
    var io = app.io;
    var query = req.body;
    var videoRef = query['stat[videoRef]'];
    var session = query['stat[sessionId]'];
    var localContext = query['stat[localContext]'];
    var action = query['stat[action]'];
    var actionType = query['stat[actionType]'];
    var subject = query['stat[subject]'];
    var timestamp = parseInt(query['stat[timestamp]']);

    var incrementHash = {};
    var pushLinkHash = {};
    incrementHash[`${action}.count`] = 1;
    pushLinkHash[`${action}.stamps`] = timestamp;

    var queryHash = {};
    queryHash["sessionName"] = session;
    queryHash["videoPath"] = videoRef;
    queryHash["playerNumber"] = subject;

    Stat.update(queryHash, {$inc: incrementHash, $push: pushLinkHash}, { upsert: true, new: true}, function(err, stats) {
        if (err) {
            res.send(err);
        }
        res.json({stats: stats});
    });

    io.emit('update', {session: session});
};
