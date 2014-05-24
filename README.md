# gulp-phantom [![Build Status](https://travis-ci.org/cognitom/gulp-phantom.svg?branch=master)](https://travis-ci.org/cognitom/gulp-phantom) [![NPM version](https://badge.fury.io/js/gulp-phantom.svg)](http://badge.fury.io/js/gulp-phantom)

A [PhantomJS](http://phantomjs.org/) plugin for [gulp](https://github.com/gulpjs/gulp). This plugin read the source from `gulp.src` as a script of PhantomJS, and record the output into the `through` object. So you can execute and convert multiple scripts into the texts. It's handy for testing or scraping webpages.


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
      ext: json
    }))
    .pipe(gulp.dest("./data/"));
});
```

or write it in CoffeeScript. When using Coffee in PhantomJS, `coffee()` needed.

```coffeescript
gulp = requier 'gulp'
coffee = require 'gulp-coffee'
phantom = require 'phantom'

gulp.task 'phantom', ->
  gulp.src './phantom/*.coffee'
  .pipe coffee()
  .pipe phantom ext:'.json'
  .pipe gulp.dest './data/'
```

### Example PhantomJS Script

The script like below can get the JSON from the table on the website.

```coffeescript
page = (require 'webpage').create()

page.open "http://examplesite.com/", ->
  result = page.evaluate ->
    for row in $('table#ex > tbody').children()
      for cell in $(row).children()
        $(cell).text()
  console.log JSON.stringify result
  phantom.exit()
```


### Example Dir Structure

- /
	- data/
		- schedule-table.json (generated)
	- phantom/
		- schedule-table.coffee
	- gulpfile.js
	- package.json


## Options

You can change the extension easily by `ext` option.

- `ext: '.txt'`
- `trim: false` Trim newline at the end of file: true or false (default)

Other options are the same as what's supported by `phantomjs`.

- `cookiesFile: <val>` Sets the file name to store the persistent cookies
- `config: <val>` Specifies JSON-formatted configuration file
- `debug: <val>` Prints additional warning and debug message: 'true' or 'false' (default)
- `diskCache: <val>` Enables disk cache: 'true' or 'false' (default)
- `ignoreSslErrors: <val>` Ignores SSL errors (expired/self-signed certificate errors): 'true' or 'false' (default)
- `loadImages: <val>` Loads all inlined images: 'true' (default) or 'false'
- `localStoragePath: <val>` Specifies the location for offline local storage
- `localStorageQuota: <val>` Sets the maximum size of the offline local storage (in KB)
- `localToRemoteUrlAccess: <val>` Allows local content to access remote URL: 'true' or 'false' (default)
- `maxDiskCacheSize: <val>` Limits the size of the disk cache (in KB)
- `outputEncoding: <val>` Sets the encoding for the terminal output, default is 'utf8'
- `remoteDebuggerPort: <val>` Starts the script in a debug harness and listens on the specified port
- `remoteDebuggerAutorun: <val>` Runs the script in the debugger immediately: 'true' or 'false' (default)
- `proxy: <val>` Sets the proxy server, e.g. '--proxy=http://proxy.company.com:8080'
- `proxyAuth: <val>` Provides authentication information for the proxy, e.g. ''-proxy-auth=username:password'
- `proxyType: <val>` Specifies the proxy type, 'http' (default), 'none' (disable completely), or 'socks5'
- `scriptEncoding: <val>` Sets the encoding used for the starting script, default is 'utf8'
- `webSecurity: <val>` Enables web security, 'true' (default) or 'false'
- `sslProtocol: <val>` Sets the SSL protocol (supported protocols: 'SSLv3' (default), 'SSLv2', 'TLSv1', 'any')
- `sslCertificatesPath: <val>` Sets the location for custom CA certificates (if none set, uses system default)
- `help` Shows this message and quits
- `version` Prints out PhantomJS version


## Related

- [node-phantom](https://github.com/alexscheelmeyer/node-phantom) is another approach for PhantomJS. You can send commands from Node to PhantomJS via sockets.
- [gulp-spawn](https://github.com/hparra/gulp-spawn) is recommended plugin for calling shell from gulp. But it needs some tricks to use with PhantomJS.

