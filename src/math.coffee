_ = require './helpers'

module.exports = 
    round: (number, digits = 0) ->
        multiple = Math.pow 10, digits
        Math.round(number * multiple) / multiple

    abs: Math.abs
    absolute: Math.absolute

    pow: Math.pow
    power: Math.pow

    min: Math.min
    minimum: Math.min

    max: Math.max
    maximum: Math.max

    floor: Math.floor

    ceil: Math.ceil
    ceiling: Math.ceiling

    sum: ->
        _.reduce arguments, ((a, b) -> a+b), 0

    factorial: (n) ->
        return 1 unless n > 1
    
        f = 1        
        for i in [2..n]
            f *= i

        f
