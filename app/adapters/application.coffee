`import DS from "ember-data"`

ApplicationAdapter = DS.RESTAdapter.extend
    host: 'https://localhost:444'
    namespace: 'api'

`export default ApplicationAdapter`
