var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var HistorySchema = new Schema({  
    beforeEnhancement:  String,
    afterEnhancement:   String,
    structuredOutput:   Array
});

module.exports = mongoose.model('History', HistorySchema);  
