_ = require './helpers'
math = require './math'

class Calculator
    constructor: (@distribution) ->

    pmf: ->
        new Pmf @distribution

    cdf: ->
        new Cdf @distribution

    mean: ->
        _.sum(@distribution.values)/@distribution.values.length
        
    median: ->
        values = _.sortBy @distribution.values, (a) -> a
        i = Math.round values.length/2
        values[i-1]
    
    mode: ->
        # piggyback on PMF method
    
    mean_deviation: (mu, power = 1) ->
        mu ?= @mean()
        deviations = (Math.pow(x - mu,  power) for x in @distribution.values)
        new Distribution(deviations, false).calculate.mean()

    variance: (mu) ->
        @mean_deviation mu, 2

    skewness: (mu) ->
        m2 = @mean_deviation mu, 2
        m3 = @mean_deviation mu, 3

        m3 / Math.pow(m2, 3/2)
        
    pearson_skewness: (mu) ->
        mu ?= @mean()
        median = @median()
        dev = @stddev()
        
        3*(mu-median)/dev
    
    stddev: ->
        Math.sqrt @variance.apply @, arguments
    
    range: ->
        [Math.min.apply(null, @distribution.values), Math.max.apply(null, @distribution.values)]
    
    interquartile_range: ->
        # piggyback on CDF method
        
    rank: ->
        # piggyback on CDF method
    
    frequency: (n) ->
        if n
            occurrences = @distribution.values.filter (value) -> value is n
            occurrences.length
        else
            @distribution.values.length

class Histogram
    constructor: (@distribution) ->
        @values = {}
        
        for x in @distribution.values
            @values[x] = (@values[x] or 0) + 1

    # creates a normalized histogram, also known 
    # as a probability mass function
    normalize: ->
        pmf = _.clone @
        size = _.size pmf.values

        for key, count of pmf.values
            pmf.values[key] = count/size

        pmf

    # creates a histogram with cumulated frequencies or probabilities, 
    # also known as a cumulative distribution function
    cumulate: ->
        cdf = _.clone @
        tuples = _.items @values
        sorted_tuples = _.sortBy tuples, (a) -> parseFloat a[0] 

        running_tally = 0
        for tuple in sorted_tuples
            [key, value] = tuple
            cdf.values[key] = running_tally + value
            running_tally = cdf.values[key]
    
        cdf

    # Puts the distribution into bins.
    # The keys are the center value, so e.g. a bin called 
    # 40 with an interval of 10 comprises values between 35 
    # and 44
    bin: (interval) ->
        values = _.groupBy @distribution.values, (value) -> Math.round(value/interval)*interval
        new Pmf values

Histogram::empty = ->
    new Histogram {values: []}

# shortcuts

Pmf = (distribution) -> 
    new Histogram(distribution).normalize()    

Cdf = (distribution) ->
    new Histogram(distribution).cumulate()

class Distribution
    constructor: (@values, @precalculations) ->
        # if nothing is specified, we calculate every summary value
        # we can think of
        @calculate = new Calculator @
        @precalculations ?= _.functions @calculate
        
        for calculation in @precalculations
            @[calculation] = @calculate[calculation]()

    normalize: (range = {}) ->
        options = {top: 1}
        range = _.extend(range, options)
    
        if range.bottom
            min = Math.min.apply null, @values
            ratio = range.bottom/min
        else if range.top
            max = Math.max.apply null, @values
            ratio = range.top/max

        values = @values.map (value) -> value*ratio        
        new Distribution values, @precalculations

    round: (digits = 0) ->
        values = @values.map (value) -> math.round value, digits
        
        new Distribution values, @precalculations

    trim: (options) ->
        if options.percentage
            'todo'
        else if options.lt or options.gt
            'todo'
        else if options.stddev
            'todo'

    to: (type) ->
        switch type.toLowerCase()
            when 'pmf'
                'todo'
            when 'cdf'
                'todo'

    difference: (distribution, options) ->
        # relative risk
        if options.relative
            'todo'
        # regular difference
        else
            'todo'

    partition: (n) ->
        _.partition(@values, n).map (partition) -> new Distribution partition, @precalculations

    sample: (n, options) ->
        s = random.sample @values, n, options.replacement
        new Distribution s, @precalculations

    # resampling differs from sampling in that resampling generates random
    # values that fit the distribution instead of picking random values from
    # the existing data.
    resample: (n, options) ->
        # create a CDF

exports.Distribution = Distribution
exports.Histogram = Histogram
