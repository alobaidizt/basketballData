var mongoose = require('mongoose');  
var Schema = mongoose.Schema;

var StatSchema = new Schema({  
  sessionName:        String,
  videoPath:          String,
  playerNumber:       String,
  playerTeam:         String,
  twoPointAttempt:    {},
  twoPointMade:       {},
  threePointAttempt:  {},
  threePointMade:     {},
  freeThrowAttempt:   {},
  freeThrowMade:      {},
  assist:             {},
  foul:               {},
  rebound:            {},
  turnover:           {},
  steal:              {}
});

module.exports = mongoose.model('Stat', StatSchema);  
