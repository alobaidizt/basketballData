/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'insight-sports',
    podModulePrefix: 'insight-sports/pods',
    environment: environment,
    rootURL: '/',
    hinting: false,
    locationType: 'history',
    EmberENV: {
      FORCE_JQUERY: true,
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      },
      EXTEND_PROTOTYPES: {
        Date: false,
        String: true,
        Function: false,
        Array: true
      }
    },

    APP: {
      // Here you can pass flags/options to your application instance
      // when it is created
    },
    emblemOptions: {
      quiet: true,
      blueprints: true
    },
    jwplayer: {
      key: 'G1hfcAyttrVB2tlvNdz7NnR90s/vXVK8GIZl7w=='

    },

    'ember-cli-toggle': {
      includedThemes: ['light', 'default', 'flip'],
      defaultTheme: 'light'
    },
    'ember-animatable': {
        include: ['bounce']
    },
    contentSecurityPolicy: {
	  'default-src': " https://www.youtube.com/ ", // Use 'none' if empty
	  'script-src': "'self' 'unsafe-eval' https://www.youtube.com/ https://s.ytimg.com/ ",
	  'font-src': "'self' fonts.gstatic.com",
      'connect-src': "'self' http://localhost:3000 http://104.131.117.229:3000 https://104.131.117.229:444 ws://localhost:7000 localhost:7000 wss://nowsportz.com:7000 ws://nowsportz.com:7000 nowsportz.com:7000 http://nowsportz.com",

	  'img-src': "'self' data:",
	  'style-src': "'self' https://fonts.googleapis.com https://fonts.googleapis.com ",
	  'media-src': "'self'"
    },
    'ember-cli-notifications': {
      icons: 'font-awesome'
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
