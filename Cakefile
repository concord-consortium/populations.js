fs     = require 'fs'
{exec} = require 'child_process'

config =
  yuic: '../yuicompressor/build/yuicompressor-2.4.7.jar'  # download from http://yuilibrary.com/download/yuicompressor/

appFiles  = [
  'helpers'
  'constants'
  'agent'
]

task 'compile', 'Build single application file', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
      console.log "reading src/#{file}.coffee"
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'dist/populations.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      console.log 'concatenating all files'
      throw err if err
      exec 'coffee --compile dist/populations.coffee', (err, stdout, stderr) ->
        console.log 'compiling to js'
        throw err if err
        console.log stdout + stderr
        fs.unlink 'dist/populations.coffee', (err) ->
          throw err if err
          console.log 'Done.'


task 'minify', 'minify compiled *.js file', ->
  exec 'java -jar "'+config.yuic+'" dist/populations.js -o dist/populations.min.js', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

task 'build', 'Build project to dist/populations.js and minify to dist/populations.min.js', ->
  invoke 'compile'
  invoke 'minify'