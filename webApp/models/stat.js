var mongoose = require('mongoose');  
var Schema = mongoose.Schema;
var Mixed = Schema.Types.Mixed;

var StatSchema = new Schema({  
  sessionName:        String,
  videoPath:          String,
  playerNumber:       String,
  playerTeam:         String,
  twoPointAttempt:    { type: Mixed, default: { count: 0, stamps: [] } },
  twoPointMade:       { type: Mixed, default: { count: 0, stamps: [] } },
  threePointAttempt:  { type: Mixed, default: { count: 0, stamps: [] } },
  threePointMade:     { type: Mixed, default: { count: 0, stamps: [] } },
  freeThrowAttempt:   { type: Mixed, default: { count: 0, stamps: [] } },
  freeThrowMade:      { type: Mixed, default: { count: 0, stamps: [] } },
  assist:             { type: Mixed, default: { count: 0, stamps: [] } },
  foul:               { type: Mixed, default: { count: 0, stamps: [] } },
  rebound:            { type: Mixed, default: { count: 0, stamps: [] } },
  turnover:           { type: Mixed, default: { count: 0, stamps: [] } },
  steal:              { type: Mixed, default: { count: 0, stamps: [] } }
}, {collection: 'stats', minimize: false, strict: false});

StatSchema.statics.findAndModify = function (query, sort, doc, options, callback) {
  return this.collection.findAndModify(query, sort, doc, options, callback);
};

module.exports = mongoose.model('Stat', StatSchema);  
