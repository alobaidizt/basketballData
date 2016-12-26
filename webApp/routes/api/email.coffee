Email = require('../../models/email')
co    = require("bluebird").coroutine

postEmail = co ({ email }) ->
  record = new Email(email: email)
  yield record.save()

module.exports =
  postEmail: postEmail
