(function() {
  var PLUGIN_NAME, fs, gutil, path, spawn, through;

  spawn = require('child_process').spawn;

  through = require('through2');

  fs = require('fs');

  path = require('path');

  gutil = require('gulp-util');

  PLUGIN_NAME = 'gulp-phantom';

  module.exports = function(options) {
    var args, cmnd;
    if (options == null) {
      options = {};
    }
    cmnd = 'phantomjs';
    args = [];
    if ((options.loadImages != null) && !options.loadImages) {
      args.push('--load-images=false');
    }
    args.push('/dev/stdin');
    return through.obj(function(file, encoding, callback) {
      var b, cd, ext, program, stdin, str;
      if (file.isNull()) {
        this.push(file);
        return callback();
      }
      if (file.isStream()) {
        this.emit('error', new gutil.PluginError(PLUGIN_NAME, 'Streaming not supported'));
        return callback();
      }
      cd = path.dirname(file.path);
      ext = options.ext ? options.ext : '.txt';
      file.path = gutil.replaceExtension(file.path, ext);
      program = spawn(cmnd, args);
      b = new Buffer(0);
      program.stdout.on('readable', (function(_this) {
        return function() {
          var chunk, _results;
          _results = [];
          while (chunk = program.stdout.read()) {
            _results.push(b = Buffer.concat([b, chunk], b.length + chunk.length));
          }
          return _results;
        };
      })(this));
      program.stdout.on('end', (function(_this) {
        return function() {
          if (options.trim) {
            b = new Buffer(b.toString('utf8').replace(/[\n\r]+$/m, ''));
          }
          file.contents = b;
          _this.push(file);
          return callback();
        };
      })(this));
      str = file.contents.toString('utf8');
      str = str.replace(/require\('.\//g, "require('" + cd + "/");
      str = str.replace(/require\(".\//g, "require(\"" + cd + "/");
      str = str.replace(/require\('..\//g, "require('" + cd + "/../");
      str = str.replace(/require\("..\//g, "require(\"" + cd + "/../");
      stdin = new Buffer(str);
      return program.stdin.write(stdin, function() {
        return program.stdin.end();
      });
    });
  };

}).call(this);
