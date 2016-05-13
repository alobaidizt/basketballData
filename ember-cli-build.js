/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
    stylusOptions: {
      //includePaths: [
        //'bower_components/bootstap/dist/css',
        //'node_modules/ember-paper/app/styles'
      //]
    }
  });

  app.import('bower_components/fontawesome/css/font-awesome.css');
  app.import('bower_components/fontawesome/fonts/fontawesome-webfont.ttf');
  app.import('bower_components/bootstrap/dist/css/bootstrap.css');
  app.import('bower_components/materialize/dist/css/materialize.css');
  app.import('bower_components/materialize/dist/js/materialize.js');
  app.import('bower_components/jquery/dist/jquery.js');
  app.import('bower_components/socket.io-client/socket.io.js');

  return app.toTree();
};
