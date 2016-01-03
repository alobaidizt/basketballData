`import Ember from 'ember'`
`import LogicMixin from '../../../mixins/logic'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | logic'

# Replace this with your real tests.
test 'it works', (assert) ->
  LogicObject = Ember.Object.extend LogicMixin
  subject = LogicObject.create()
  assert.ok subject
