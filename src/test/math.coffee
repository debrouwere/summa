should = require 'should'
math = require '../math'

module.exports = 
    "round numbers up to x decimal places": ->
        expectations = [
            [9.234, 0, 9]
            [9.234, 1, 9.2]
            [9.234, 2, 9.23]
            [9.234, 3, 9.234]
            [9.234, 4, 9.234]
            [-0.33, 1, -0.3]
            [-0.37, 1, -0.4]
            ]

        for [number, digits, result] in expectations
            math.round(number, digits).should.equal result

    "calculate factorials": ->
        expectations = [
            [0, 1]
            [1, 1]
            [2, 2]
            [3, 6]
            [4, 24]
            [5, 120]
            ]

        for [number, expectation] in expectations
            math.factorial(number).should.equal expectation
