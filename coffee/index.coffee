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

	through.obj (file, encoding, callback) ->
		
		if file.isNull()
			@push file
			return callback()
		
		if file.isStream()
			@emit 'error', new gutil.PluginError PLUGIN_NAME, 'Streaming not supported'
			return callback()
		
		# create temporary file because phantomjs doesn't support stdin
		src = file.path
		tmp = path.dirname(src) + path.sep + '___tmp___' + path.basename(src)
		tmp_contents = file.contents.toString 'utf8'
		fs.writeFileSync tmp, tmp_contents
		
		# relace the extension
		ext = if options.ext then options.ext else '.txt'
		file.path = gutil.replaceExtension file.path, ext
		
		# PhantomJS
		program = spawn cmnd, args.concat tmp
		
		# create buffer
		b = new Buffer 0
		
		# add data to buffer
		program.stdout.on 'readable', =>
			while chunk = program.stdout.read()
				b = Buffer.concat [b, chunk], b.length + chunk.length
		
		# return data
		program.stdout.on 'end', =>
			fs.unlinkSync tmp
			b = new Buffer b.toString('utf8').replace /[\n\r]+$/m, '' if options.trim
			file.contents = b
			@push file
			callback()
