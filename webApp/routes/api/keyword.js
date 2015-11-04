var mongoose = require('mongoose');  
var Keyword = require('../../models/keyword');

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
  var found = false;
    Keyword.find(function(err, keywords) {
        if (err) {
            res.send(err);
        }
        var masks = keywords.map(function(keyword) {
          return keyword.masks
        };
        var names = keywords.map(function(keyword) {
          return keyword.name
        };
        var words = names
          .concat(masks)
          .reduce(function(a,b) {
          a.concat(b);
        };
        
        for(var i = 0; i < words.length; i++) {
          if (words[i] === name) {
            found = true;
          }
        }
    });
    if (found) {
      res.json({info: "word already exist"});
    } else {
      Keyword.update({ name: name }, {$push: { masks: req.body.mask}},{ upsert: true }, function(err, numAffected, raw) {
          if (err) {
              res.send(err);
          }
          res.json({numAffected: numAffected});
      });
    }
};

module.exports.deleteKeywordByName = function(req, res, name) {  
    Keyword.findOneAndRemove({ name: name }, function(err) {
        if (err) {
            res.send(err);
        }
        res.sendStatus(200);
    });
};

