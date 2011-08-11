should = require 'should'
_ = require '../helpers'

module.exports =
    "smartly partition an array into chunks": ->
        _.partition([1,2,3,4,5], 3).should.eql [[1,2],[3,4],[5]]
        _.partition([1,2,3,4,5,6,7,8,9,10,11], 4).should.eql [[1,2,3],[4,5,6],[7,8,9],[10,11]]
