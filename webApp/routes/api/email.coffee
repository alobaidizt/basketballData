mongoose = require('mongoose')
Email = require('../../models/email')

module.exports.postEmail = (req) ->
  obj = req.body.email
  email = new Email({"email": obj.email})
  email.save (err)

