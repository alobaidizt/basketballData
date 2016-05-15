`import Ember from 'ember'`

round = Ember.Helper.helper ([value, decimals]) ->
  value    = parseFloat(value)
  decimals = parseFloat(decimals)
  value.toFixed(decimals)

`export default round`
