{spawn} = require 'child_process'
through  = require 'through2'
fs = require 'fs'
path = require 'path'
gutil = require 'gulp-util'

PLUGIN_NAME = 'gulp-phantom'

module.exports = (options = {}) ->

	# build a command with arguments
	cmnd = 'phantomjs'
	args = []
	# Sets the file name to store the persistent cookies
	args.push '--cookies-file=' + options.cookiesFile if options.cookiesFile
	# Specifies JSON-formatted configuration file
	args.push '--config=' + options.config if options.config
	# Prints additional warning and debug message: 'true' or 'false' (default)
	args.push '--debug=true' if options.debug
	# Enables disk cache: 'true' or 'false' (default)
	args.push '--disk-cache=true' if options.diskCache
	# Ignores SSL errors (expired/self-signed certificate errors): 'true' or 'false' (default)
	args.push '--ignore-ssl-errors=true' if options.ignoreSslErrors
	# Loads all inlined images: 'true' (default) or 'false'
	args.push '--load-images=false' if options.loadImages? and not options.loadImages
	# Specifies the location for offline local storage
	args.push '--local-storage-path=' + options.localStragePath if options.localStragePath
	# Sets the maximum size of the offline local storage (in KB)
	args.push '--local-storage-quota=' + options.localStrageQuota if options.localStrageQuota
	# Allows local content to access remote URL: 'true' or 'false' (default)
	args.push '--local-to-remote-url-access=true' if options.localToRemoteUrlAccess
	# Limits the size of the disk cache (in KB)
	args.push '--max-disk-cache-size=' + options.maxDiskCacheSize if options.maxDiskCacheSize
	# Sets the encoding for the terminal output, default is 'utf8'
	args.push '--output-encoding=' + options.outputEncoding if options.outputEncoding
	# Starts the script in a debug harness and listens on the specified port
	args.push '--remote-debugger-port=' + options.remoteDebuggerPort if options.remoteDebuggerPort
	# Runs the script in the debugger immediately: 'true' or 'false' (default)
	args.push '--remote-debugger-autorun=true' if options.remoteDebuggerAutorun
	# Sets the proxy server, e.g. '--proxy=http://proxy.company.com:8080'
	args.push '--proxy=' + options.proxy if options.proxy
	# Provides authentication information for the proxy, e.g. '--proxy-auth=username:password'
	args.push '--proxy-auth=' + options.proxyAuth if options.proxyAuth
	# Specifies the proxy type, 'http' (default), 'none' (disable completely), or 'socks5'
	args.push '--proxy-type=' + options.proxyType if options.proxyType
	# Sets the encoding used for the starting script, default is 'utf8'
	args.push '--script-encoding=' + options.scriptEncoding if options.scriptEncoding
	# Enables web security, 'true' (default) or 'false'
	args.push '--web-security=false' if options.webSecurity? and not options.webSecurity
	# Sets the SSL protocol (supported protocols: 'SSLv3' (default), 'SSLv2', 'TLSv1', 'any')
	args.push '--ssl-protocol=' + options.sslProtocol if options.sslProtocol
	# Sets the location for custom CA certificates (if none set, uses system default)
	args.push '--ssl-certificates-path=' + options.sslCertificatesPath if options.sslCertificatesPath
	# Shows this message and quits
	args.push '--help' if options.help
	# Prints out PhantomJS version
	args.push '--version' if options.version
	
	args.push '/dev/stdin'

	through.obj (file, encoding, callback) ->
		
		if file.isNull()
			@push file
			return callback()
		
		if file.isStream()
			@emit 'error', new gutil.PluginError PLUGIN_NAME, 'Streaming not supported'
			return callback()
			
		# Current Dir
		cd = path.dirname file.path
		
		# replace the extension
		ext = if options.ext then options.ext else '.txt'
		file.path = gutil.replaceExtension file.path, ext
		
		# PhantomJS
		program = spawn cmnd, args
		
		# create buffer
		b = new Buffer 0
		
		# add data to buffer
		program.stdout.on 'readable', =>
			while chunk = program.stdout.read()
				b = Buffer.concat [b, chunk], b.length + chunk.length
		
		# return data
		program.stdout.on 'end', =>
			b = new Buffer b.toString('utf8').replace /[\n\r]+$/m, '' if options.trim
			file.contents = b
			@push file
			callback()
		
		# replace relative path to absoulute
		str = file.contents.toString 'utf8'
		str = str.replace /require\('.\//g, "require('#{cd}/"
		str = str.replace /require\(".\//g, "require(\"#{cd}/"
		str = str.replace /require\('..\//g, "require('#{cd}/../"
		str = str.replace /require\("..\//g, "require(\"#{cd}/../"
		
		# write file buffer to program
		stdin = new Buffer str
		program.stdin.write stdin, -> program.stdin.end()
