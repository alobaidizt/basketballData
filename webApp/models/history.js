var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var HistorySchema = new Schema({  
    sessionId:          String,
    timestamp:          Number,
    beforeEnhancement:  String,
    afterEnhancement:   String,
    structuredOutput:   Array
});

module.exports = mongoose.model('History', HistorySchema);  
