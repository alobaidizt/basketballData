var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var ConfigSchema = new Schema({  
    actionCaptureDelay: String,
    detectableActions: Array,
    stitchesHash: Array
});

module.exports = mongoose.model('config', ConfigSchema);  
