const gulp = require('gulp');
const server = require('./index').server;

gulp.task('default', function() {
  server.start();
});
