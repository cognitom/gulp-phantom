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
    if (options.cookiesFile) {
      args.push('--cookies-file=' + options.cookiesFile);
    }
    if (options.config) {
      args.push('--config=' + options.config);
    }
    if (options.debug) {
      args.push('--debug=true');
    }
    if (options.diskCache) {
      args.push('--disk-cache=true');
    }
    if (options.ignoreSslErrors) {
      args.push('--ignore-ssl-errors=true');
    }
    if ((options.loadImages != null) && !options.loadImages) {
      args.push('--load-images=false');
    }
    if (options.localStragePath) {
      args.push('--local-storage-path=' + options.localStragePath);
    }
    if (options.localStrageQuota) {
      args.push('--local-storage-quota=' + options.localStrageQuota);
    }
    if (options.localToRemoteUrlAccess) {
      args.push('--local-to-remote-url-access=true');
    }
    if (options.maxDiskCacheSize) {
      args.push('--max-disk-cache-size=' + options.maxDiskCacheSize);
    }
    if (options.outputEncoding) {
      args.push('--output-encoding=' + options.outputEncoding);
    }
    if (options.remoteDebuggerPort) {
      args.push('--remote-debugger-port=' + options.remoteDebuggerPort);
    }
    if (options.remoteDebuggerAutorun) {
      args.push('--remote-debugger-autorun=true');
    }
    if (options.proxy) {
      args.push('--proxy=' + options.proxy);
    }
    if (options.proxyAuth) {
      args.push('--proxy-auth=' + options.proxyAuth);
    }
    if (options.proxyType) {
      args.push('--proxy-type=' + options.proxyType);
    }
    if (options.scriptEncoding) {
      args.push('--script-encoding=' + options.scriptEncoding);
    }
    if ((options.webSecurity != null) && !options.webSecurity) {
      args.push('--web-security=false');
    }
    if (options.sslProtocol) {
      args.push('--ssl-protocol=' + options.sslProtocol);
    }
    if (options.sslCertificatesPath) {
      args.push('--ssl-certificates-path=' + options.sslCertificatesPath);
    }
    if (options.help) {
      args.push('--help');
    }
    if (options.version) {
      args.push('--version');
    }
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
      args.push(file.path);
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
