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

gulp.task('moveHtml', ()=>{
  gulp.src('src/**/*.html')
    .pipe(gulp.dest('dist'));
});

gulp.task('watch', ()=>{
  gulp.watch('src/**/*.coffee', ['coffee']);
  gulp.watch('src/**/*.scss', ['sass']);
  gulp.watch('src/**/*.html', ['moveHtml']);
});

gulp.task('compile', ['sass', 'coffee', 'moveHtml'], ()=>{});

gulp.task('default', ['compile', 'watch'], function() {
  server.start();
});
