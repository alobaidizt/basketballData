var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var EmailSchema = new Schema({  
  email: String,
});
module.exports = mongoose.model('Email', EmailSchema);  
