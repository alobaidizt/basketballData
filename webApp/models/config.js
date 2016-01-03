var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var ConfigSchema = new Schema({  
    actionCaptureDelay: Integer,
    bbDetectableActions: Array,
    stitchesHash: Array
});

module.exports = mongoose.model('config', ConfigSchema);  
