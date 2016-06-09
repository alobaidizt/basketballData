`import Ember from 'ember'`

MaterializeModalComponent = Ember.Component.extend
  showFooter: false

  isTotal: Ember.computed.equal('title', 'Total')

  init: ->
    @_super()
    $(document).ready =>
      Ember.run.scheduleOnce 'afterRender', this, '_func'
  _func: ->
    $(".#{@get('modalId')}").leanModal
      dismissible: true
      opacity: .5
      in_duration: 500
      out_duration: 200
      ready: ->
      complete: ->
          

`export default MaterializeModalComponent`
