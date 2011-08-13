# Summa is a little library for descriptive (summary) statistics.

exports._ = require './helpers'
exports[lib] = require "./#{lib}" for lib in ['distributions', 'probability']
exports.VERSION = '0.2.0'
