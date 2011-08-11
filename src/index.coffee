exports._ = require './helpers'
exports[lib] = require "./#{lib}" for lib in ['distributions', 'math', 'probability', 'random']
exports.VERSION = '0.2.0'
