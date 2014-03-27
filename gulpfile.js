process.env.PWD = process.cwd();
var appDir = process.env.PWD + '/app/';
var NODE_ENV = process.env.NODE_ENV;

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
var clean           = require('gulp-clean');
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
    styles: appDir + '/public/styles'
  }
};

var outputFiles = {
  css: 'style.css',
  js: 'main.js'
};

if (NODE_ENV == 'development') {
  console.log('dev');
  var lrport = 35729;
  var livereload = require('gulp-livereload');
  var lrserver = require('tiny-lr')();

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
    return gulp.src(appDir + '/index.html')
      .pipe(embedlivereload())
      .pipe(gulp.dest(appDir));
  });
}


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
    script: appDir + 'app.js',
    ext: 'js jade coffee'
  });
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
    'watch',
    'nodemon',
    callback
  );
});

gulp.task('heroku:', function (callback) {
  runSequence(
    'clean-tmp',
    ['server-coffee', 'coffeeify', 'stylus'],
    callback
  );
});

