process.env.PWD = process.cwd() + '/app/';

// Requirements
var gulp            = require('gulp');

// Gulp plugins
var browserify      = require('gulp-browserify');
var coffee          = require('gulp-coffee');
var stylus          = require('gulp-stylus');
var concat          = require('gulp-concat');
var uglify          = require('gulp-uglify');
var minifyCss       = require('gulp-minify-css');
var runSequence     = require('run-sequence');
var livereload      = require('gulp-livereload');
var lrserver        = require('tiny-lr')();
var clean           = require('gulp-clean');
var nodemon         = require('gulp-nodemon');

var lrport = 35729;

var paths = {
  views: {
    jade: process.env.PWD + '/views/coffee',
    js: process.env.PWD + '/views'
  },
  models: {
    coffee: process.env.PWD + '/models/coffee',
    js: process.env.PWD + '/models'
  },
  routes: {
    coffee: process.env.PWD + '/routes/coffee',
    js: process.env.PWD + '/routes'
  },
  public: {
    coffee: process.env.PWD + '/public/coffee',
    scripts: process.env.PWD + '/public/scripts',
    styl: process.env.PWD + '/public/styl',
    styles: process.env.PWD + '/public/styles'
  }
};

var outputFiles = {
  css: 'style.css',
  js: 'main.js'
};

gulp.task('server-coffee', function () {
  gulp.src(paths.models.coffee + '/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest(paths.models.js))
    .pipe(livereload(lrserver));
  gulp.src(paths.routes.coffee + '/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest(paths.routes.js))
    .pipe(livereload(lrserver));
});

// Load modules with browserify, compile coffee and concat
gulp.task('coffeeify', function () {
  return gulp.src(paths.public.coffee + '/main.coffee', {read: false })
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat(outputFiles.js))
    .pipe(gulp.dest(paths.public.scripts))
    .pipe(livereload(lrserver));
});

gulp.task('stylus', function () {
  return gulp.src(paths.public.styl + '/*.styl')
    .pipe(stylus())
    .pipe(concat(outputFiles.css))
    .pipe(minifyCss({relativeTo: './public/styl'}))
    .pipe(gulp.dest(paths.public.styles))
    .pipe(livereload(lrserver));
});

// Inject livereload script into index.html
gulp.task('embedLivereload', function () {
  return gulp.src(process.env.PWD + '/index.html')
    .pipe(embedlivereload())
    .pipe(gulp.dest(process.env.PWD));
});

// Copy compiled css to build
gulp.task('build-styles', function () {
  return gulp.src(paths.tmp.styles + '/' + outputFiles.css)
    .pipe(minifyCss())
    .pipe(gulp.dest(paths.build.styles));
});

// Copy compiled js to build
gulp.task('build-scripts', function () {
  return gulp.src(paths.tmp.scripts + '/' + outputFiles.js)
    .pipe(uglify())
    .pipe(gulp.dest(paths.build.scripts));
});

gulp.task('clean-tmp', function () {
  gulp.src(paths.public.scripts, { read: false })
    .pipe(clean({ force: true }));
  gulp.src(paths.public.styles, { read: false })
    .pipe(clean({ force: true }));
});

gulp.task('clean-build', function () {
  return gulp.src(dirs.build, { read: false })
    .pipe(clean({ force: true }));
});

gulp.task('nodemon', function () {
  nodemon({ 
    script: 'app/app.js',
    ext: 'js jade coffee'
  });
});

//gulp.task('server', function () {
  //http.createServer(
    //ecstatic({ root: dirs.tmp })
  //).listen(8080);
  //console.log('Listening on 8080...');
//});

gulp.task('serve-lr', function () {
  lrserver.listen(lrport);
});

gulp.task('watch', function () {
  gulp.watch(paths.models.coffee + '/*.coffee', ['server-coffee']);
  gulp.watch(paths.routes.coffee + '/*.coffee', ['server-coffee']);
  gulp.watch(paths.public.coffee + '/*.coffee', ['coffeeify']);
  gulp.watch(paths.public.styl + '/*.styl', ['stylus']);

  console.log('Watching for changes...');
});

gulp.task('default', function (callback) {
  runSequence(
    'clean-tmp',
    ['server-coffee', 'coffeeify', 'stylus'],
    //'serve-lr',
    'watch',
    'nodemon',
    callback
  );
});

gulp.task('heroku:production', function (callback) {
  runSequence(
    'clean-tmp',
    ['server-coffee', 'coffeeify', 'stylus'],
    callback
  );
});

