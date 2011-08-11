should = require 'should'
distributions = require '../distributions'

simple_odd = new distributions.Distribution [1,2,3,4,5,6,7,8,9]

module.exports = 
    "calculate a median": ->
        simple_odd.median.should.equal 5

    "find the mode(s) of a distribution": ->
        simple_odd.is_multimodal.should.be.true
        simple_odd.modes.length.should.equal simple_odd.values.length
