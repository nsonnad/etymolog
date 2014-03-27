process.env.PWD = __dirname || process.cwd();
/**
 * Module dependencies.
 */

var express = require('express');
var http = require('http');
var path = require('path');
var livereload = require('express-livereload');
var routes = require('./routes');
var words = require('./routes/words');

var app = express();
var liveReloadPort = 35729;

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(process.env.PWD, 'views'));
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(express.static(path.join(process.env.PWD, 'public')));

app.configure('development', function () {
  livereload(app, config={});
});

app.use(app.router);

app.get('/', routes.index);
app.get('/word/:id', routes.index);
app.get('/_id', routes.words.getWordById);
app.get('/_etym/:id', routes.words.getEtym);
app.get('/_word', routes.words.getNodeByWord);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
