should = require 'should'
distributions = require '../distributions'

simple_odd  = new distributions.Distribution [1..9]
simple_odd2 = new distributions.Distribution [2..10]

module.exports = 
    "calculate a median": ->
        simple_odd.median.should.equal 5

    "find the mode(s) of a distribution": ->
        simple_odd.is_multimodal.should.be.true
        simple_odd.modes.length.should.equal simple_odd.values.length

    "compare two distributions": ->
        simple_odd.difference(simple_odd2).should.eql (1 for i in [1..9])

    "compute relative risk between two distributions": ->
        expectations = simple_odd.values.map (value, i) -> simple_odd2.values[i] / value
        
        simple_odd.difference(simple_odd2, relative:true).should.eql expectations

    "find the absolute difference between values in two distributions": ->
        absolute = simple_odd2.difference(simple_odd, absolute:yes)
        relative = simple_odd2.difference(simple_odd, absolute:no)
        inverse_relative = simple_odd.difference(simple_odd2)
        
        relative.should.not.eql absolute
        inverse_relative.should.eql absolute
