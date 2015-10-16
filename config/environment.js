/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'basketball-data',
    podModulePrefix: 'basketball-data/pods',
    environment: environment,
    firebase: 'https://basketballData.firebaseio.com/',
    baseURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },
    emblemOptions: {
      blueprints: true
    },
    contentSecurityPolicy: {
	  'default-src': "'none'",
	  'script-src': "'self' 'unsafe-eval' https://cdn.firebase.com/ ",
	  'font-src': "'self' fonts.gstatic.com",
	  'connect-src': "'self' http://localhost:3000 http://104.131.117.229:3000 http://127.0.0.1:3000",
	  'img-src': "'self' data:",
	  'style-src': "'self' https://fonts.googleapis.com ",
	  'media-src': "'self'"
    }
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {

  }

  return ENV;
};
