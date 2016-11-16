mongoose = require('mongoose')
Schema   = mongoose.Schema

ConfigSchema = new Schema(
  clipDuration:       Number
  actionCaptureDelay: String
  detectableActions:  Array
  stitchesHash:       Array
)

module.exports = mongoose.model('config', ConfigSchema)
