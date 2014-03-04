
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var http = require('http');
var path = require('path');
var livereload = require('express-livereload');

var app = express();
var words = require('./routes/words');
var liveReloadPort = 35729;

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(express.static(path.join(__dirname, 'public')));

app.configure('development', function () {
  livereload(app, config={});
});

app.use(app.router);

app.get('/', routes.index);
app.get('/id/:id', words.getWordById);
app.get('/word/:name', words._getIdByName);
app.get('/etym/:id', words.getEtym);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
