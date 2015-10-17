`import DS from "ember-data"`

ApplicationAdapter = DS.RESTAdapter.extend
    host: 'https://104.131.117.229:444'
    namespace: 'api'

`export default ApplicationAdapter`
