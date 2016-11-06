var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {});

  app.import('bower_components/urijs/src/URI.min.js');
  app.import('bower_components/lodash/lodash.js');
  app.import('bower_components/font-awesome/css/font-awesome.css');
  app.import('bower_components/font-awesome/fonts/fontawesome-webfont.ttf');
  app.import('bower_components/bootstrap/dist/js/bootstrap.js');
  app.import('bower_components/bootstrap/dist/css/bootstrap.css');
  app.import('bower_components/materialize/dist/css/materialize.css');
  app.import('bower_components/materialize/dist/js/materialize.js');
  app.import('bower_components/jquery/dist/jquery.js');
  app.import('bower_components/socket.io-client/socket.io.js');
  app.import('bower_components/animate.css/animate.min.css');
  app.import('bower_components/moment-duration-format/lib/moment-duration-format.js');
  app.import('vendor/jwplayer.js');

  return app.toTree();
};
