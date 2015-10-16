`import DS from "ember-data"`

ApplicationAdapter = DS.RESTAdapter.extend
    host: 'http://104.131.117.229:3000'
    namespace: 'api'

`export default ApplicationAdapter`
