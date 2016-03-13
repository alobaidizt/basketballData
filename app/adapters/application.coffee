`import DS from "ember-data"`

ApplicationAdapter = DS.RESTAdapter.extend
    host: window.webService.servicePrefix
    namespace: 'api'

`export default ApplicationAdapter`
