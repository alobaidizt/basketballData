`import DS from 'ember-data'`
`import MF from 'model-fragments'`

Action = MF.Fragment.extend
  count:    DS.attr('number')
  stamps:   MF.array('string')

`export default Action`
