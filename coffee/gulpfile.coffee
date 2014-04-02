gulp = require 'gulp'
coffee = require 'gulp-coffee'
phantom = require '../'

gulp.task 'coffee', ->
  gulp.src './coffee/index.coffee'
  .pipe coffee()
  .pipe gulp.dest './'
  
gulp.task 'phantom', ->
  gulp.src './test/fixtures/test.js'
  .pipe phantom ext:'.data'
  .pipe gulp.dest './tmp/'
  

gulp.task 'default', ->
  gulp.watch './coffee/index.coffee', ['coffee']