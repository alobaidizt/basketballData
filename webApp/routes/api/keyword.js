var mongoose = require('mongoose');  
var Keyword = require('../../models/keyword');
var map = require('arr-map');

module.exports.addKeyword = function(req, res) {  
    var keyword = new Keyword(req.body.keyword);
    keyword.save(function(err) {
        if (err) {
            res.send(err);
        }
        res.json({keyword: keyword});
    });
};

module.exports.getAllKeywords = function(req, res) {  
    Keyword.find(function(err, keywords) {
        if (err) {
            res.send(err);
        }
        res.json({keywords: keywords});
    });
};

module.exports.getSingleKeyword = function(req, res, id) {  
    Keyword.findById(id, function(err, keyword) {
        if (err) {
            res.send(err);
        }
        res.json({keyword: keyword});
    });
};

module.exports.updateKeyword = function(req, res, id) {  
    Keyword.findByIdAndUpdate(id, {$set: req.body.keyword}, function(err, keyword) {
        if (err) {
            res.send(err);
        }
        res.json({keyword: keyword});
    });
};

module.exports.deleteKeyword = function(req, res, id) {  
    Keyword.findByIdAndRemove(id, function(err) {
        if (err) {
            res.send(err);
        }
        res.sendStatus(200);
    });
};

// Query By name
module.exports.getKeywordByName = function(req, res, name) {  
    Keyword.findOne({ name: name }, function(err, keyword) {
        if (err) {
            res.send(err);
        }
        res.json({keyword: keyword});
    });
};

module.exports.updateKeywordByName = function(req, res, name) {  
  var mask = req.body.mask.toLowerCase();
    Keyword.find(function(err, keywords) {
      var isFound = false;
        if (err) {
            res.send(err);
        }
        var words = [];
        // TODO: rewrite this. Looks inefficient. do both in one map
        var masks = map(keywords, function(keyword) {
          return keyword.masks;
        });
        var names = map(keywords, function(keyword) {
          return keyword.name;
        });

        map(masks, function(ele) { words = words.concat(ele);}); 
        words = words.concat(names);
        
        for(var i = 0; i < words.length; i++) {
          if (words[i] === mask) {
            isFound = true;
          }
        }
      if (isFound || (mask === "")) {
        res.json(404, {info: "word already exist"});
        // req.abort();
      } else {
        Keyword.update({ name: name }, {$push: { masks: mask}},{ upsert: true }, function(err, numAffected, raw) {
          if (err) {
              res.send(err);
          }
          res.json({numAffected: numAffected});
        });
      }
    });
};

module.exports.deleteKeywordByName = function(req, res, name) {  
    Keyword.findOneAndRemove({ name: name }, function(err) {
        if (err) {
            res.send(err);
        }
        res.sendStatus(200);
    });
};
