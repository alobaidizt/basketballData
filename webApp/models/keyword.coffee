mongoose = require('mongoose')
Schema = mongoose.Schema

KeywordSchema = new Schema(
  name: String
  masks: Array
)

module.exports = mongoose.model('Keyword', KeywordSchema)
