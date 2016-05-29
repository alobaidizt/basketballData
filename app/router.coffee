`import Ember from 'ember';`
`import config from './config/environment';`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  @route 'calibration', { path: '/calibration' }
  @route 'commentator',   { path : '/commentator' }
  @route 'home',   { path : '/' }
  @route 'monitor', { path: '/monitor' }

`export default Router;`
