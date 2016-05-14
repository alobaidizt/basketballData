`import DS from 'ember-data'`
`import MF from 'model-fragments'`

Stat =  DS.Model.extend
  sessionName:        DS.attr('string')
  videoPath:          DS.attr('string')
  playerNumber:       DS.attr('string')
  playerTeam:         DS.attr('string')
  twoPointAttempt:    MF.fragment('action')
  twoPointMade:       MF.fragment('action')
  threePointAttempt:  MF.fragment('action')
  threePointMade:     MF.fragment('action')
  freeThrowAttempt:   MF.fragment('action')
  freeThrowMade:      MF.fragment('action')
  assist:             MF.fragment('action')
  foul:               MF.fragment('action')
  rebound:            MF.fragment('action')
  turnover:           MF.fragment('action')
  steal:              MF.fragment('action')

`export default Stat`
