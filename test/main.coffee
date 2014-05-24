should = require 'should'
phantom = require '../'
gutil = require 'gulp-util'
fs = require 'fs' 
path = require 'path'

createFile = (phantomFileName, contents) ->
  base = path.join __dirname, 'fixtures'
  filePath = path.join base, phantomFileName

  new gutil.File
    cwd: __dirname
    base: base
    path: filePath
    contents: contents || fs.readFileSync filePath

describe 'gulp-phantom', () ->
  describe 'phantom()', () ->
    
    @timeout 10000
    
    it 'should pass file when it isNull()', (done) ->
      stream = phantom()
      emptyFile =
        isNull: () -> true
      stream.on 'data', (data) ->
        data.should.equal emptyFile
        done()
      stream.write emptyFile
    
    it 'should emit error when file isStream()', (done) ->
      stream = phantom()
      streamFile =
        isNull: () -> false
        isStream: () -> true
      stream.on 'error', (err) ->
        err.message.should.equal 'Streaming not supported'
        done()
      stream.write streamFile
    
    it 'should execute single phantom file', (done) ->
      phantomFile = createFile 'test.js'
    
      stream = phantom()
      stream.on 'data', (outputFile) ->
        should.exist outputFile
        should.exist outputFile.path
        should.exist outputFile.relative
        should.exist outputFile.contents
        outputFile.path.should.equal path.join __dirname, 'fixtures', 'test.txt'
        String(outputFile.contents).should.equal fs.readFileSync path.join(__dirname, 'expect/test.txt'), 'utf8'
        done()
      stream.write phantomFile
    
    it 'should trim newline at EOF', (done) ->
      phantomFile = createFile 'trim.js'
    
      stream = phantom trim:true
      stream.on 'data', (outputFile) ->
        should.exist outputFile
        should.exist outputFile.path
        should.exist outputFile.relative
        should.exist outputFile.contents
        outputFile.path.should.equal path.join __dirname, 'fixtures', 'trim.txt'
        String(outputFile.contents).should.equal fs.readFileSync path.join(__dirname, 'expect/trim.txt'), 'utf8'
        done()
      stream.write phantomFile
    
    it 'should execute phantom file with require', (done) ->
      phantomFile = createFile 'require1.js'
    
      stream = phantom()
      stream.on 'data', (outputFile) ->
        should.exist outputFile
        should.exist outputFile.path
        should.exist outputFile.relative
        should.exist outputFile.contents
        outputFile.path.should.equal path.join __dirname, 'fixtures', 'require1.txt'
        String(outputFile.contents).should.equal fs.readFileSync path.join(__dirname, 'expect/require1.txt'), 'utf8'
        done()
      stream.write phantomFile

    it 'should execute phantom file with require the script in another dir', (done) ->
      phantomFile = createFile 'require2.js'
    
      stream = phantom()
      stream.on 'data', (outputFile) ->
        should.exist outputFile
        should.exist outputFile.path
        should.exist outputFile.relative
        should.exist outputFile.contents
        outputFile.path.should.equal path.join __dirname, 'fixtures', 'require2.txt'
        String(outputFile.contents).should.equal fs.readFileSync path.join(__dirname, 'expect/require2.txt'), 'utf8'
        done()
      stream.write phantomFile