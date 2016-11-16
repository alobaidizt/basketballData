mongoose = require('mongoose')
Schema   = mongoose.Schema

HistorySchema = new Schema(
  sessionId:          String
  timestamp:          Number
  beforeEnhancement:  String
  afterEnhancement:   String
  structuredOutput:   Array
)

module.exports = mongoose.model('History', HistorySchema)
