process.env.PWD = process.cwd();
var appDir = process.env.PWD + '/app/';

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
var rimraf          = require('gulp-rimraf');
var nodemon         = require('gulp-nodemon');

var paths = {
  views: {
    jade: appDir + '/views/coffee',
    js: appDir + '/views'
  },
  models: {
    coffee: appDir + '/models/coffee',
    js: appDir + '/models'
  },
  routes: {
    coffee: appDir + '/routes/coffee',
    js: appDir + '/routes'
  },
  public: {
    coffee: appDir + '/public/coffee',
    scripts: appDir + '/public/scripts',
    styl: appDir + '/public/styl',
    styles: appDir + '/public/styles',
    images: appDir + '/public/images'
  }
};

var outputFiles = {
  css: 'style.css',
  js: 'main.js'
};

gulp.task('server-coffee', function () {
  gulp.src(paths.models.coffee + '/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest(paths.models.js));
  gulp.src(paths.routes.coffee + '/*.coffee')
    .pipe(coffee())
    .pipe(gulp.dest(paths.routes.js));
});

// Load modules with browserify, compile coffee and concat
gulp.task('coffeeify', function () {
  return gulp.src(paths.public.coffee + '/main.coffee', {read: false })
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat(outputFiles.js))
    .pipe(gulp.dest(paths.public.scripts));
});

gulp.task('stylus', function () {
  return gulp.src(paths.public.styl + '/*.styl')
    .pipe(stylus())
    .pipe(concat(outputFiles.css))
    .pipe(minifyCss({relativeTo: './public/styl'}))
    .pipe(gulp.dest(paths.public.styles));
});

gulp.task('copy-img', function () {
  return gulp.src([
    './node_modules/select2/select2.png',
    './node_modules/select2/select2-spinner.gif'
  ], { base: './node_modules/' })
    .pipe(gulp.dest(paths.public.images));
});

gulp.task('rimraf-tmp', function () {
  gulp.src(paths.routes.js + '/*.js', { read: false })
    .pipe(rimraf({ force: true }));
  gulp.src(paths.views.js + '/*.js', { read: false })
    .pipe(rimraf({ force: true }));
  gulp.src(paths.public.scripts, { read: false })
    .pipe(rimraf({ force: true }));
  gulp.src(paths.public.styles, { read: false })
    .pipe(rimraf({ force: true }));
});

if (process.env.NODE_ENV == 'development') {
  var lrport = 35729;
  var livereload = require('gulp-livereload');
  var lrserver = require('tiny-lr')();
  lrserver.listen(lrport);

  var notifyLivereload = function (e) {
    var fileName = require('path').relative(appDir, e.path);

    lrserver.changed({
      body: {
        files: fileName
      }
    });
  };

  // Inject livereload script into index.html
  gulp.task('watch', function () {
    gulp.watch(paths.routes.coffee + '/*.coffee', ['server-coffee']);
    gulp.watch(paths.routes + '/*.js')
      .on('change', notifyLivereload);

    gulp.watch(paths.public.coffee + '/*.coffee', ['coffeeify']);
    gulp.watch(paths.public.scripts + '/*.js')
      .on('change', notifyLivereload);

    gulp.watch(paths.public.styl + '/*.styl', ['stylus']);
    gulp.watch(paths.public.styles + '/*.css')
      .on('change', notifyLivereload);

    console.log('Watching for changes...');
  });

  gulp.task('nodemon', function () {
    nodemon({ 
      script: appDir + 'app.js',
      ext: 'js jade coffee'
    });
  });

  gulp.task('default', function (callback) {
    runSequence(
      'rimraf-tmp',
      ['copy-img', 'server-coffee', 'coffeeify', 'stylus'],
      'watch',
      'nodemon',
      callback
    );
  });
}

gulp.task('heroku:production', function (callback) {
  runSequence(
    'rimraf-tmp',
    ['copy-img', 'server-coffee', 'coffeeify', 'stylus'],
    callback
  );
});

