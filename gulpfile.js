const gulp = require('gulp');
const server = require('./index').server;
const sass = require('gulp-sass');
const coffee = require('gulp-coffee');


gulp.task('coffee', function() {
  gulp.src('src/**/*.coffee')
    .pipe(coffee({ bare: false }))
    .pipe(gulp.dest('dist'));
});

gulp.task('sass', ()=>{
  gulp.src('src/**/*.scss')
    .pipe(sass({ outputStyle: 'expanded' }))
    .pipe(gulp.dest('dist'));
});

gulp.task('default', ['sass'], function() {
  server.start();
});
