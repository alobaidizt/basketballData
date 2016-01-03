var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var HistorySchema = new Schema({  
    timestamp:          String,
    beforeEnhancement:  String,
    afterEnhancement:   String,
    structuredOutput:   Array
});

module.exports = mongoose.model('History', HistorySchema);  
