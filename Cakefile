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
    modules = ['helpers', 'probability', 'distributions', 'index']
    
    code = ''
    
    for name in modules
        module = fs.readFileSync "lib/#{name}.js"
        code += """
            require['math'] = new function() { return math; }
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

    # TODO: we should also compile a version which includes the underscore.js and math libraries
    # and another which (in addition to the above) includes the coffeescript parser.
    # That way, we can limit summa to a one-file dependency (or not, for people who dislike that)
    
    unless process.env.MINIFY is 'false'
        {parser, uglify} = require 'uglify-js'
        code = uglify.gen_code uglify.ast_squeeze uglify.ast_mangle parser.parse code

    fs.writeFileSync 'summa.min.js', header + code

task 'test', 'run the summa test suite', ->
    exec 'expresso lib/test/*', (error, stdout, stderr) ->
        process.stderr.write stderr
