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
	args.push '--load-images=false' if options.loadImages? and not options.loadImages
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
