Email = require('../../models/email')
co    = require("bluebird").coroutine

postEmail = co (email) ->
  email = new Email(email: email)
  yield Email.save(email)

module.exports =
  postEmail: postEmail
