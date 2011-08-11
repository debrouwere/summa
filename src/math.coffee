module.exports =
    round: (value, digits = 0) ->
        multiple = Math.pow 10, digits
        Math.round(number * multiple) / multiple

    pow: Math.pow
    power: Math.pow

    min: Math.min
    minimum: Math.min

    max: Math.max
    maximum: Math.max

    factorial: (n) ->
        return 1 unless n > 1
    
        f = 1        
        for i in [2..n]
            f *= i

        f
