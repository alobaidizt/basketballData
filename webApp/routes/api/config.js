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

    Config.update(
        {}, 
        {
          $addToSet: {
          bbDetectableActions: action
          }
        }
    );
};
