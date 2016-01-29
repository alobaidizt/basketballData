var mongoose = require('mongoose');  
var Config = require('../../models/config');
var map = require('arr-map');

module.exports.updateDelay = function(req, res) {  
    var delay = req.body.delay;

    Config.update(
        {}, 
        {
          $set: {
          actionCaptureDelay: delay
          }
        },
        {upsert: true}
    );
};

module.exports.updateStitches = function(req, res) {  
    var stitch = req.body.stitch;

    Config.update(
        {}, 
        {
          $addToSet: {
          stitchesHash: stitch
          }
        }
    );
};

module.exports.updateActions = function(req, res) {  
  var action = req.body.action;

  Config.find(function(err, config) {
    var isFound = false;
    if (err) {
        res.send(err);
    }
    var actions = config.detectableActions;
    for(var i = 0; i < actions.length; i++) {
      if (actions[i] === action) {
        isFound = true;
      }
    }

    if (isFound || (action === "")) {
      res.json(404, {info: "word already exist"});
      req.abort();
    } else {
    Config.update(
        {}, 
        {
          $addToSet: {
          detectableActions: action
          }
        },
        { upsert: true }
    );
    }
  });
};
