`import DS from 'ember-data'`
`import MF from 'model-fragments'`

Config =  DS.Model.extend
  clipDuration:       DS.attr('number')
  actionCaptureDelay: DS.attr('string')
  detectedActions:    MF.array('string')
  stitchesHash:       MF.array()

`export default Config`
