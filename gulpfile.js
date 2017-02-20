'use strict';

const gulp = require('gulp');
const server = require('./index').server;
const sass = require('gulp-ruby-sass-ns');
const coffee = require('gulp-coffee');
const plumber = require('gulp-plumber');
const exec = require('child_process').exec;


gulp.task('coffee', function() {
  gulp.src('src/**/*.coffee')
    .pipe(plumber())
    .pipe(coffee({ bare: false }))
    .pipe(gulp.dest('dist'));
});

gulp.task('sass', ()=>{
  gulp.src('src/**/*.scss')
    .pipe(plumber())
    .pipe(sass({ style: 'expanded' }))
    .pipe(gulp.dest('dist'));
});

gulp.task('moveHtml', ()=>{
  gulp.src('src/**/*.html')
    .pipe(plumber())
    .pipe(gulp.dest('dist'));
});

gulp.task('watch', ()=>{
  gulp.watch('src/**/*.coffee', ['coffee']);
  gulp.watch('src/**/*.scss', ['sass']);
  gulp.watch('src/**/*.html', ['moveHtml']);
});


gulp.task('compile', ['coffee', 'sass', 'moveHtml'], ()=>{});


gulp.task('start', (cb)=>{
  var name = null;
  let option = process.argv[3];
  if (option) {
    name = option.match(/\w[\w-\.]*/)[0];
  }
  let term = `cd src && mkdir ${ name } && cd ${ name } && touch ${ name }.coffee && touch ${ name }-demo.coffee && touch ${ name }.scss && touch ${ name }.html && cd .. && cd ..`;
  exec(term);
  cb();
});

gulp.task('default', ['compile', 'watch'], function() {
  server.start();
});
