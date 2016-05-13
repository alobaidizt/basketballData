`import DS from 'ember-data'`

Stat =  DS.Model.extend
  sessionName:        DS.attr('string')
  videoPath:          DS.attr('string')
  playerNumber:       DS.attr('string')
  playerTeam:         DS.attr('string')
  twoPointAttempt:    DS.attr('number')
  twoPointMade:       DS.attr('number')
  threePointAttempt:  DS.attr('number')
  threePointMade:     DS.attr('number')
  freeThrowAttempt:   DS.attr('number')
  freeThrowMade:      DS.attr('number')
  assist:             DS.attr('number')
  foul:               DS.attr('number')
  rebound:            DS.attr('number')
  turnover:           DS.attr('number')
  steal:              DS.attr('number')

`export default Stat`
