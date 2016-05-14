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

    var videoUri = req.body.videoUri;
    var session = req.body.session;

    for (var i = 0; i < req.body.outputArraySize; i++) {
      var eventDataArr = req.body["outputArray[" + i + "][]"];
      var actionStamp = eventDataArr[2];
      var action = eventDataArr[3];
      var subject = eventDataArr[4];

      var incrementHash = {};
      var pushLinkHash = {};
      incrementHash[`${action}.count`] = 1;
      pushLinkHash[`${action}.uriLinks`] = `${videoUri}#t=${actionStamp}`;

      var queryHash = {};
      queryHash["sessionName"] = session;
      queryHash["playerNumber"] = subject;

      console.log(incrementHash);
      console.log(pushLinkHash);
      console.log(queryHash);

      Stat.update(queryHash, {$inc: incrementHash, $push: pushLinkHash}, { multi: true, upsert: true }, function(err, stats) {
          if (err) {
              res.send(err);
          }
          res.json({stats: stats});
      });
    }

    io.emit('update', {session: session});
};
