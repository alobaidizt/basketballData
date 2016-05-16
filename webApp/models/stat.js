var mongoose = require('mongoose');  
var Schema = mongoose.Schema;
var ObjectId = Schema.Types.ObjectId;

var ActionSchema = new Schema({  
  count:        { type: Number, default: 0 },
  stamps:       []
});

var StatSchema = new Schema({  
  sessionName:        String,
  videoPath:          String,
  playerNumber:       String,
  playerTeam:         String,
  twoPointAttempt:    ActionSchema,
  twoPointMade:       ActionSchema,
  threePointAttempt:  ActionSchema,
  threePointMade:     ActionSchema,
  freeThrowAttempt:   ActionSchema,
  freeThrowMade:      ActionSchema,
  assist:             ActionSchema,
  foul:               ActionSchema,
  rebound:            ActionSchema,
  turnover:           ActionSchema,
  steal:              ActionSchema
});

module.exports = mongoose.model('Stat', StatSchema);  
