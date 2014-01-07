module.exports = function (grunt) {
  grunt.initConfig({

    clean: {
      build: ['build'],
      compile: ['scripts/*.js', 'styles/*.css']
    },

    coffee: {
      compile: {
        files: {
          'scripts/app.js': ['scripts/*.coffee']
        }
      }
    },

    less: {
      compile: {
        options: {
          paths: ['styles']
        },
        files: {
          'styles/main.css': ['styles/main.less']
        }
      }
    },

    connect: {
      server: {
        options: {
          port: 9000,
          hostname: "0.0.0.0",
          base: './',
          livereload: true
        }
      }
    },

    rev: {
      files: {
        src: ['build/**/*.{js,css,png,jpg}']
      }
    },

    watch: {
      options: {
        livereload: true
      },
      files: ['scripts/*.coffee', 'styles/*less', '*.html'],
      tasks: ['compile']
    },

    useminPrepare: {
      html: 'index.html',
      options: {
        dest: 'build'
      }
    },

    usemin: {
      html: ['build/*.html'],
      css: ['styles/*.css'],
      options: {
        dirs: ['build']
      }
    },

    copy: {
      main: {
        files: [
          { src: 'images/*', dest: 'build/' },
          { src: '*.html', dest: 'build/' },
          { src: 'data/*', dest: 'build/' }
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-css');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-usemin');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-rev');

  grunt.registerTask('build', [
    'clean:build',
    'less',
    'coffee',
    'useminPrepare',
    'concat',
    'cssmin',
    'uglify',
    'copy',
    'rev',
    'usemin'
  ]);

  grunt.registerTask('compile', [
    'clean:compile',
    'coffee',
    'less'
  ]);

  grunt.registerTask('server', [
    'compile',
    'connect:server',
    'watch'
  ]);

};