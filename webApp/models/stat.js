var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var StatSchema = new Schema({  
  sessionName:        String,
  videoPath:          String,
  playerNumber:       String,
  playerTeam:         String,
  twoPointAttempt:    Number,
  twoPointMade:       Number,
  threePointAttempt:  Number,
  threePointMade:     Number,
  freeThrowAttempt:   Number,
  freeThrowMade:      Number,
  assist:             Number,
  foul:               Number,
  rebound:            Number,
  turnover:           Number,
  steal:              Number
});

module.exports = mongoose.model('Stat', StatSchema);  
