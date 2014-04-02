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
    return through.obj(function(file, encoding, callback) {
      var b, ext, program, src, tmp, tmp_contents;
      if (file.isNull()) {
        this.push(file);
        return callback();
      }
      if (file.isStream()) {
        this.emit('error', new gutil.PluginError(PLUGIN_NAME, 'Streaming not supported'));
        return callback();
      }
      src = file.path;
      tmp = path.dirname(src) + path.sep + '___tmp___' + path.basename(src);
      tmp_contents = file.contents.toString('utf8');
      fs.writeFileSync(tmp, tmp_contents);
      ext = options.ext ? options.ext : '.txt';
      file.path = gutil.replaceExtension(file.path, ext);
      program = spawn(cmnd, args.concat(tmp));
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
      return program.stdout.on('end', (function(_this) {
        return function() {
          fs.unlinkSync(tmp);
          if (options.trim) {
            b = new Buffer(b.toString('utf8').replace(/[\n\r]+$/m, ''));
          }
          file.contents = b;
          _this.push(file);
          return callback();
        };
      })(this));
    });
  };

}).call(this);
