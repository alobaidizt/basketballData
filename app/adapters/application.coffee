`import DS from "ember-data"`

ApplicationAdapter = DS.RESTAdapter.extend
    host: 'http://127.0.0.1:3000'
    namespace: 'api'

`export default ApplicationAdapter`
