# gulp-phantom [![Build Status](https://travis-ci.org/cognitom/gulp-phantom.svg?branch=master)](https://travis-ci.org/cognitom/gulp-phantom) [![NPM version](https://badge.fury.io/js/gulp-phantom.svg)](http://badge.fury.io/js/gulp-phantom)

A [PhantomJS](http://phantomjs.org/) plugin for [gulp](https://github.com/wearefractal/gulp).


## Install

```bash
brew install phantomjs
npm install gulp-phantom --save-dev
```


## Usage

```javascript
var gulp = require("gulp");
var phantom = require("gulp-phantom");

gulp.task('phantom', function(){
  gulp.src("./phantom/*.js")
    .pipe(phantom({
      ext: csv
    }))
    .pipe(gulp.dest("./csv/"));
});
```

or write it in CoffeeScript.

```coffeescript
gulp = requier 'gulp'
coffee = require 'gulp-coffee'
phantom = require 'phantom'

gulp.task 'phantom', ->
  gulp.src './phantom/*.coffee'
  .pipe coffee()
  .pipe phantom ext:'.csv'
  .pipe gulp.dest './csv/'
```


## Options

~~The options are the same as what's supported by `phantomjs`.~~

- `ext: '.txt'`
- `trim: false` Trim newline at the end of file: true or false (default)
- `loadImages: true` Loads all inlined images: true (default) or false
