const gulp = require('gulp');
const server = require('./index').server;
const sass = require('gulp-sass');

gulp.task('sass', ()=>{
  gulp.src('src/**/*.scss')
    .pipe(sass({ outputStyle: 'expanded' }))
    .pipe(gulp.dest('dist'));
});

gulp.task('default', ['sass'], function() {
  server.start();
});
