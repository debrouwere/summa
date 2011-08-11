exec  = require('child_process').exec
fs    = require 'fs'
summa = require './src/index'

header = """
  /**
   * Summa v#{summa.VERSION}
   * http://github.com/stdbrouw/summa
   *
   * Copyright 2011, Stijn Debrouwere
   * Released under the MIT License
   */

"""

task 'clean', 'clean the build', ->
    exec 'rm -rf lib', -> console.log 'Cleaned ./lib'

task 'build', 'build the JavaScript source files', ->
    console.log 'Starting build'
    exec 'coffee -o lib -c src', ->
        console.log 'Build complete'

# heavily inspired by Jeremy Ashkenas' CoffeeScript build script
task 'build:browser', 'merge and uglify the code for usage in a browser environment', ->
    # order is important: we can't require anything that isn't loaded yet
    modules = ['helpers', 'math', 'probability', 'random', 'distributions', 'index']
    
    code = ''
    
    for name in modules
        module = fs.readFileSync "lib/#{name}.js"
        code += """
            require['./#{name}'] = new function() {
                var module = {};
                var exports = this;
                #{module}
                _.extend(exports, module.exports)
            };
            """
    code = """
        this.summa = function() {
            var modules = {};
            function require(path){ return require[path]; }
            #{code}
            return require['./index'];
        }();
        """
    
    {parser, uglify} = require 'uglify-js'
    code = uglify.gen_code uglify.ast_squeeze uglify.ast_mangle parser.parse code

    fs.writeFileSync 'summa.min.js', header + code

task 'test', 'run the summa test suite', ->
    exec 'expresso lib/test/*', (error, stdout, stderr) ->
        process.stderr.write stderr
