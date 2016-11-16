`import Ember from 'ember'`
`import HelpersMixin from 'insight-sports/mixins/helpers'`

ModalActionButtonComponent = Ember.Component.extend HelpersMixin,
  time: Em.computed 'stamp', ->
    seconds = @get('stamp')
    @hhmmss(seconds)

  actionType: Em.computed 'type', ->
    type = @get('type')

    switch type
      when 'twoPointAttempt' then '2 Pt. A'
      when 'twoPointMade' then '2 Pt. M'
      when 'threePointAttempt' then '3 Pt. A'
      when 'threePointMade' then '3 Pt. M'
      when 'freeThrowAttempt' then 'FT A'
      when 'freeThrowMade' then 'FT M'
      when 'assist' then 'Assist'
      when 'foul' then 'Foul'
      when 'rebound' then 'Rebound'
      when 'turnover' then 'T/O'
      when 'steal' then 'Steal'

  player: Em.computed 'model.playerNumber', 'playerNumber', ->
    player = @get('model.playerNumber')
    if Em.isEqual(player, 'Total')
      return "##{@get('playerNumber')}"

    "#" + player

`export default ModalActionButtonComponent`
