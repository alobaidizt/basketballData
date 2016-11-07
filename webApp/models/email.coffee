mongoose = require('mongoose')
Schema = mongoose.Schema

EmailSchema = new Schema(
  email: String
)
module.exports = mongoose.model('Email', EmailSchema)
