// Requirements
var gulp            = require('gulp');
var http            = require('http');
var ecstatic        = require('ecstatic');

// Gulp plugins
var browserify      = require('gulp-browserify');
var stylus          = require('gulp-stylus');
var jade            = require('gulp-jade');
var concat          = require('gulp-concat');
var uglify          = require('gulp-uglify');
var minifyCss       = require('gulp-minify-css');
var runSequence     = require('run-sequence');
var livereload      = require('gulp-livereload');
var embedLivereload = require('gulp-embedlr');
var clean           = require('gulp-clean');

var dirs = {
  app: __dirname + '/app',
  tmp: __dirname + '/.tmp',
  build: __dirname + '/build'
};

var paths = {
  app: {
    scripts: dirs.app + '/scripts',
    styles: dirs.app + '/styles'
  },
  tmp: {
    scripts: dirs.tmp + '/scripts',
    styles: dirs.tmp + '/styles'
  },
  build : {
    scripts: dirs.build + '/scripts',
    styles: dirs.build + '/styles'
  }
};

var outputFiles = {
  css: 'main.css',
  js: 'main.js'
};

// Load modules with browserify, compile coffee and concat
gulp.task('coffeeify', function () {
  return gulp.src(paths.app.scripts + '/main.coffee', {read: false })
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    .pipe(concat(outputFiles.js))
    .pipe(gulp.dest(paths.tmp.scripts))
    .pipe(livereload());
});

gulp.task('stylus', function () {
  return gulp.src(paths.app.styles + '/*.styl')
    .pipe(stylus())
    .pipe(concat(outputFiles.css))
    .pipe(gulp.dest(paths.tmp.styles))
    .pipe(livereload());
});

gulp.task('jade', function () {
  return gulp.src(dirs.app + '/*.jade')
    .pipe(jade())
    .pipe(gulp.dest(dirs.tmp))
    .pipe(livereload());
});

// Inject livereload script into index.html
gulp.task('embedLivereload', ['jade'], function () {
  return gulp.src(dirs.tmp + '/index.html')
    .pipe(embedLivereload())
    .pipe(gulp.dest(dirs.tmp));
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

// Copy html to build
gulp.task('build-html', function () {
  return gulp.src(dirs.tmp + '/*.html')
    .pipe(gulp.dest(dirs.build));
});

gulp.task('clean-tmp', function () {
  return gulp.src(dirs.tmp, { read: false })
    .pipe(clean({ force: true }));
});

gulp.task('clean-build', function () {
  return gulp.src(dirs.build, { read: false })
    .pipe(clean({ force: true }));
});

gulp.task('server', function () {
  http.createServer(
    ecstatic({ root: dirs.tmp })
  ).listen(8080);
  console.log('Listening on 8080...');
});

gulp.task('watch', function () {
  gulp.watch(paths.app.scripts + '/*.coffee', ['coffeeify']);
  gulp.watch(paths.app.styles + '/*.styl', ['stylus']);
  gulp.watch(dirs.app + '/*.jade', ['jade']);

  console.log('Watching for changes...');
});

gulp.task('default', function (callback) {
  runSequence(
    'clean-tmp',
    ['coffeeify', 'stylus', 'jade'],
    'embedLivereload',
    'server',
    'watch',
    callback
  );
});

gulp.task('build', function (callback) {
  runSequence(
    'clean-tmp',
    'clean-build',
    ['coffeeify', 'stylus', 'jade'],
    ['build-scripts', 'build-styles', 'build-html'],
    callback
  );
});

