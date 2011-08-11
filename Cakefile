exec = require('child_process').exec

task 'clean', 'clean the build', ->
    exec 'rm -rf lib', -> console.log 'Cleaned ./lib'

task 'build', 'build the JavaScript source files', ->
    console.log 'Starting build'
    exec 'coffee -o lib -c src', ->
        console.log 'Build complete'

task 'test', 'run the summa test suite', ->
    exec 'expresso lib/test/*', (error, stdout, stderr) ->
        process.stdout.write stderr
