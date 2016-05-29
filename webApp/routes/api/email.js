var mongoose = require('mongoose');  
var Email = require('../../models/email');

module.exports.postEmail = function(req, res) {  
    var obj = req.body.email;
    var email = new Email({"email": obj.email});
    email.save(function(err) {
        if (err) {
            res.send(err);
        }
        res.json({email: email});
    });
};

