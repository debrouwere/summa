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

    # another one of those functions where it's easy to be off by one
    "trim a distribution to x standard deviations around the mean": ->
        trimmed = simple_odd.trim(stddev: 1)
        trimmed.count.should.equal 5
        trimmed.interval.should.eql [3, 7]
        
    "trim a distribution to the x% of the data, centered on the mean": ->

    "trim a distribution to only include values in a certain range": ->
        trimmed = simple_odd.trim(lt: 5)
        trimmed.count.should.equal 5
        trimmed.interval.should.eql [5, 9]

        trimmed = simple_odd.trim(gt: 8)
        trimmed.count.should.equal 8
        trimmed.interval.should.eql [1, 8]

        trimmed = simple_odd.trim(lt: 3, gt: 7)
        trimmed.count.should.equal 5
        trimmed.interval.should.eql [3, 7]
