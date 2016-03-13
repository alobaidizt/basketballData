var mongoose = require('mongoose');  
var Config = require('../../models/config');
var map = require('arr-map');

module.exports.getDelay = function(req, res) {  
    Config.find(function(err, config) {
        if (err) {
            res.send(err);
        }
	if (config.length > 0) {
          res.json({delay: config[0].actionCaptureDelay});
	} else {
	  res.json("error: no configs available");
	}
    });
};

module.exports.updateDelay = function(req, res) {  
    var delay = req.body.delay;

    Config.update(
        {}, 
        {
          $set: {
          actionCaptureDelay: delay
          }
        },
        {upsert: true},
	function(err, numAffected, raw) {
          if (err) {
              res.send(err);
          }
          res.json({numAffected: numAffected});
    	}
    );
};

module.exports.getStitches = function(req, res) {  
    Config.find(function(err, config) {
        if (err) {
            res.send(err);
        }
	if (config.length > 0) {
          res.json({stitches: config[0].stitchesHash});
	} else {
	  res.json("error: no configs available");
	}
    });
};

module.exports.updateStitches = function(req, res) {  
  var stitch = req.body;

  Config.find(function(err, config) {
    var isFound = false;
    if (err) {
        res.send(err);
    }
    if (config.length > 0) {
      var stitches = config[0].stitchesHash;
      for(var i = 0; i < stitches.length; i++) {
	if (JSON.stringify(stitches[i]) === JSON.stringify(stitch)) { 
          isFound = true;
        }
      }
    } else {
      var config = new Config();
      config.save(function(err) {
          if (err) {
              res.send(err);
          }
          res.json({config: config});
      });
    }

    if (isFound || (stitch === null)) {
      res.json(404, {info: "stitch hash already exist"});
    } else {
    Config.update(
        {}, 
        {
          $addToSet: {
          stitchesHash: stitch
          }
        },
        { upsert: true },
	function(err, numAffected, raw) {
          if (err) {
              res.send(err);
          }
          res.json({numAffected: numAffected});
        });
    }
  });
};

module.exports.deleteStitches = function(req, res) {  
    Config.update(
	{},
	{$set: {stitchesHash: []}},
	function(err, numAffected, raw) {
        if (err) {
            res.send(err);
        }
        res.sendStatus(200);
    });
};

module.exports.updateActions = function(req, res) {  
  var action = req.body.action;

  Config.find(function(err, config) {
    var isFound = false;
    if (err) {
        res.send(err);
    }
    if (config.length > 0) {
      var actions = config[0].detectableActions;
      for(var i = 0; i < actions.length; i++) {
        if (actions[i] === action) {
          isFound = true;
        }
      }
    } else {
      var config = new Config();
      config.save(function(err) {
          if (err) {
              res.send(err);
          }
          res.json({config: config});
      });
    }

    if (isFound || (action === "")) {
      res.json(404, {info: "word already exist"});
    } else {
    Config.update(
        {}, 
        {
          $addToSet: {
          detectableActions: action
          }
        },
        { upsert: true },
	function(err, numAffected, raw) {
          if (err) {
              res.send(err);
          }
          res.json({numAffected: numAffected});
        });
    }
  });
};

module.exports.getActions = function(req, res) {  
    Config.find(function(err, config) {
        if (err) {
            res.send(err);
        }
	if (config.length > 0) {
          res.json({actions: config[0].detectableActions});
	} else {
	  res.json("error: no configs available");
	}
    });
};

module.exports.deleteActions = function(req, res) {  
    Config.update(
	{},
	{$set: {detectableActions: []}},
	function(err, numAffected, raw) {
        if (err) {
            res.send(err);
        }
        res.sendStatus(200);
    });
};

module.exports.deleteConfigs = function(req, res) {  
    Config.remove(
	{},
	function(err, numAffected, raw) {
        if (err) {
            res.send(err);
        }
        res.sendStatus(200);
    });
};
