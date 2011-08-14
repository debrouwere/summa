should = require 'should'
_ = require '../helpers'

module.exports =
    "smartly partition an array into chunks": ->
        _.partition([1,2,3,4,5], 3).should.eql [[1,2],[3,4],[5]]
        _.partition([1,2,3,4,5,6,7,8,9,10,11], 4).should.eql [[1,2,3],[4,5,6],[7,8,9],[10,11]]

    # bisection requires careful testing because it's
    # easy to produce off-by-one errors
    "bisection: find the insertion points to keep a list in sorted order": ->
        _.bisect_left([1,2,3,3,3,4,5], 3).should.equal 2
        _.bisect([1,2,3,3,3,4,5], 3).should.equal 5
        _.bisect_left([1,2,3,3,3,4,5], 2.5).should.equal 2
        _.bisect([1,2,3,3,3,4,5], 2.5).should.equal 2
        _.bisect_left([5,4,3,3,3,1,2], 3.5).should.equal 5
        _.bisect([3,2,1,3,5,3,4], 3.5).should.equal 5
