_ = require './helpers'
math = require('math').math

# Calculator is a class that allows us to do calculations on a distribution.
# **All calculations that don't return a new distribution are housed here**, whereas those
# that do (transformations) are housed in the Distribution class, which we'll see later.
#
# Why? No particular reason, except for tidiness.
class Calculator
    constructor: (@distribution) ->

    pmf: ->
        return @_pmf if @_pmf?
        @_pmf = new Pmf @distribution

    cdf: ->
        return @_cdf if @_cdf?
        @_cdf = new Cdf @distribution

    # The arithmetic mean, also known as average, is a measure of central tendency, like
    # the median.
    #
    # The mean is the bread and butter of descriptive statistics, but it's not a very robust
    # statistic: it is easily influenced by outliers in the data.
    mean: ->
        _.sum(@distribution.values)/@distribution.values.length

    # The median is the middle value of a dataset. But datasets with an 
    # even number of observations don't have a real "middle", so they 
    # don't have a true median.
    #
    # In those cases, we'll pick the value closest to the median (using the
    # `median` method) or take the average of the two values closest to the
    # median (using the `interpolated_median` method).
    has_true_median: ->
        # any distribution with an odd amount 
        # of observations has a true median
        @distribution.values.length % 2 is 1

    # The median is another measure of central tendency, and it's defined as the
    # center value of a distribution: it separates the higher and lower halves of
    # a sample.
    #
    # The median is more robust than the mean (outliers don't sway the median) but 
    # less exact.
    median: ->
        values = _.sortBy @distribution.values, (x) -> x
        i = Math.round values.length/2
        values[i-1]

    # Some people like their medians interpolated.
    # This method calculates the average between the two middle values in an
    # even-numbered sample. This is the simplest interpolation calculation
    # possible, but less refined than e.g. using a weighted average.
    interpolated_median: ->
        if @has_true_median()
            @median()
        else
            lh = math.floor(0.5*@distribution.values.length) - 1
            math.sum(@distribution.values[lh..lh+1]...)/2

    # In the dataset [1,1,2,2,3] both 1 and 2 are a tie for the most frequent value, 
    # also known as the mode. We call datasets like that **multimodal**.
    is_multimodal: ->
        @modes().length > 1

    # The mode of a distribution is the most frequently occuring value.
    # Modes need not be unique, which is why this method always returns
    # an array.
    modes: ->
        values = _.items @pmf().values
        values = _.sortBy values, (x) -> x[1]
        [most_frequent, highest_frequency] = _.last(values)

        modes = values.filter (value) -> value[1] == highest_frequency
        modes.map (mode) -> parseFloat mode[0]

    # The mean deviation is the mean of the differences between each value
    # and the mean. So for [1,2,3] the mean is 2, the differences are [-1,0,1], 
    # of which we'll calculate the mean.
    #
    # A good observer will see that these differences tend to cancel each other out, 
    # which is why we never really care about the mean deviation, but do care about 
    # the squared mean deviation (also known as variance) and the cubed mean deviation
    # (which is used to calculate the skewness of a dataset).
    mean_deviation: (mu, power = 1) ->
        mu ?= @mean()
        deviations = (Math.pow(x - mu,  power) for x in @distribution.values)
        new Distribution(deviations, false).calculate.mean()

    variance: (mu) ->
        @mean_deviation mu, 2

    # Skewness is a measure of the asymmetry of a probability distribution.
    # If the probability density is higher to the righthand side of a 
    # distribution, that's positive skew. If the big probabilities occur
    # early on and taper off to the right, that's negative skew.
    #
    # Skewness is an interesting metric, but it's not very robust: in some
    # datasets, this measurement doesn't really correspond to how skewed we
    # intuitively think the dataset to be.
    #
    # Pearson skewness is often a more reliable measure of asymmetry.
    skewness: (mu) ->
        m2 = @mean_deviation mu, 2
        m3 = @mean_deviation mu, 3

        m3 / Math.pow(m2, 3/2)
        
    pearson_skewness: (mu) ->
        mu ?= @mean()
        median = @median()
        dev = @stddev()
        
        3*(mu-median)/dev

    # The standard deviation is a widely used unit of dispersion.
    # 
    # To give you a bit of a feel as to what a standard deviation is like: 
    # in a normal distribution (a bell curve), about 34% of the data fits
    # in one standard deviation, and 68% of the data is within one standard
    # deviation of the mean (above and below).
    # 
    # The symbol for the standard deviation is sigma. You may have heard of 
    # "six sigma", which is a method some companies use to make sure that their
    # manufactured goods all work as they should.
    #
    # The standard deviation is the square root of the variance, another (but less 
    # frequently used) unit of dispersion.
    stddev: (k = 1) ->
        k * Math.sqrt @variance.apply @, arguments

    central_moment: (k = 1) ->
        'todo'

    kurtosis: ->
        'todo'

    # The interval is the lower and upper bound of the data.
    #
    # Mathematically speaking: the set of real numbers with the property that any 
    # number that lies between two numbers in the set is also included in the set.
    interval: ->
        [@bottom(), @top()]

    bottom: ->
        Math.min.apply(null, @distribution.values)

    top: ->
        Math.max.apply(null, @distribution.values)

    # The range is the length of the smallest interval which contains all the data.
    # It is an indication of statistical dispersion, but usually not a very robust
    # one, because it only relies on two observations.
    #
    # The range is either equal to, or more often, greater than twice the standard
    # deviation.
    range: ->
        [min, max] = @interval()
        max - min

    approximate_interquartile_range: ->
        values = @distribution.values
        # we don't use @rank percentile: 25 because ordinal percentiles
        # are always rounded upwards, whereas for our approximation
        # we want the closest match, up or down
        left = math.round(0.25*values.length)
        right = values.length - left
        left_percentile = left/values.length
        right_percentile = right/values.length

        range = {}
        range[left_percentile] = @distribution.values[left-1]
        range[right_percentile] = @distribution.values[right-1]

        range

    interpolated_interquartile_range: ->
        values = @distribution.values        
        left = @index(percentile: 25)
        right = values.length - left

        lh = (@distribution.values[left-1] + @distribution.values[left]) / 2
        rh = (@distribution.values[right-1] + @distribution.values[right]) / 2

        [lh, rh]

    # The interquartile range is a measure of spread.
    # It cuts off the lowest and highest 25% of data.
    interquartile_range: ->    
        lh = @index(percentile: 25)
        rh = @index(percentile: 75)
        [@distribution.values[lh], @distribution.values[rh]]

    rank: (options) ->
        if options.value?
            math.rank @distribution.values, options.value
        else if options.percentile?
            # although the + 1/2 is really arbitrary, this is a
            # common textbook definition according to Wikipedia
            rank = options.percentile/100 * @distribution.values.length + 1/2
            # ranks are ordinal
            math.round rank
        else
            throw new Error "We can only rank given a percentile or a value"

    # Statistics traditionally talks about ranks, which go from 1 to n, 
    # but us computer programmers know better, and index lists from 0 
    # onwards. The index is the rank minus one. 
    index: (options) ->
        @rank(options) - 1

    percentile: (value) ->
        rank = @rank value: value
        math.ceil rank/@distribution.values.length * 100
    
    count: (n) ->
        if n
            occurrences = @distribution.values.filter (value) -> value is n
            occurrences.length
        else
            @distribution.values.length

# A lot of calculations make sense on both the entire dataset and a smaller 
# part of it. For example, you can count the frequency of a certain value, but 
# you can also count all data points at a time. But other calculations really
# only work for a specific range or data point, and here's a list of those.
Calculator::local = [
    'index'
    'rank'
    'percentile'
    ]

class Histogram
    constructor: (@distribution) ->
        @values = {}
        
        for x in @distribution.values
            @values[x] = (@values[x] or 0) + 1

        # if every value in our distribution is linked to 
        # an equal amount of observations, we have a
        # uniform distribution.
        first = _.keys(@values)[0]
        tally = _.values(@values)
        
        if _.every(tally, (value) => value == @values[first])
            @is_uniform = true
        else
            @is_uniform = false

    # creates a normalized histogram, also known 
    # as a probability mass function
    normalize: ->
        pmf = _.clone @
        size = pmf.distribution.values.length

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
        # When creating a new distribution, people can specifically ask
        # **which summary statistics they wish to be calculated**.
        # But if they don't ask for anything in particular, we 
        # calculate every summary value we can think of -- the computing
        # time is negligable anyway, except for really big data sets.
        @calculate = new Calculator @

        if not @precalculations?
            fns = _.functions Calculator.prototype
            @precalculations = _.reject fns, (fn) -> _.contains(Calculator::local, fn)
        
        for calculation in @precalculations
            @[calculation] = @calculate[calculation]()

    # Rebasing a data set means picking a new minimum or maximum value, and 
    # transforming the dataset to match the new range.
    # This is also commonly called normalization, but to avoid confusion, 
    # we're reserving that name to refer to the concept of converting a 
    # histogram's values from frequencies to probabilities (a normalization 
    # between 0-1).
    rebase: (range = {}) ->
        options = {top: 1}
        range = _.extend(range, options)

        # TODO: support for both a bottom *and* top argument
        if range.bottom
            min = math.min @values
            ratio = range.bottom/min
        else if range.top
            max = math.max @values
            ratio = range.top/max

        values = @values.map (value) -> value*ratio        
        new Distribution values, @precalculations

    # Sometimes, we're not interested in detail, and sometimes we
    # our data has only a couple of significant digits, both of 
    # which are good reasons for rounding the dataset.
    #
    # This method can also round to the nearest ten, hundred etc.
    # For example, dist.round(-2) will convert the dataset [17, 122]
    # to [0,100].
    round: (digits = 0) ->
        values = @values.map (value) -> math.round value, digits
        
        new Distribution values, @precalculations

    # Datasets often have outlying data, which isn't always reliable: 
    # much of it might be measurement errors or noise. In that case, 
    # trimming the dataset is a good idea.
    #
    # You can trim to either encompass a certain percentage of the data, 
    # (like 50% to get the data in the interquartile range), between a
    # certain lower or higher point, or an amount of standard deviations
    # above and below the mean.
    trim: (options) ->
        # Array#slice extracts up to but not including `end`. If we want a percentage
        # of data, that means adding one to the righthand boundary. In the other cases,
        # using _.bisect_right gives us an index that's one above where the bisection
        # would happen, which has the same effect.
        if options.percentage
            # TODO: I don't believe this is quite right yet. Perhaps it shouldn't
            # depend on @calculate.index, which is ordinal and thus inexact, whereas
            # this function needn't be.
            lh = @calculate.index(percentile: 50-math.ceil(options.percentage/2))
            rh = @calculate.index(percentile: 50+math.ceil(options.percentage/2)) + 1
        else if options.lt or options.gt
            # todo: support for lte and gte
            lh = _.bisect_left  @values, options.lt or @calculate.bottom()
            rh = _.bisect_right @values, options.gt or @calculate.top()
        else if options.stddev
            lh = _.bisect_left  @values, @calculate.mean() - options.stddev * @calculate.stddev()
            rh = _.bisect_right @values, @calculate.mean() + options.stddev * @calculate.stddev()

        new Distribution @values.slice(lh, rh), @precalculations

    # note that absolute difference and relative difference
    # are not counterpoints to each other, they're different
    # calculations altogether
    difference: (distribution, options) ->
        unless @values.length == distribution.values.length
            throw Error "Can only compare two like-sized distributions"

        sets = _.zip(@values, distribution.values)
        
        # relative risk
        if options?.relative == yes
            sets.map (value) -> value[1] / value[0]
        # absolute difference
        else if options?.absolute == yes
            sets.map (value) -> Math.abs value[1] - value[0]
        # regular difference
        else
            sets.map (value) -> value[1] - value[0]

    partition: (n) ->
        _.partition(@values, n).map (partition) -> new Distribution partition, @precalculations

    sample: (n, options) ->
        s = random.sample @values, n, options.replacement
        new Distribution s, @precalculations

    # Resampling differs from sampling in that resampling generates random
    # values that fit the distribution instead of picking random values from
    # the existing data.
    resample: (n, options) ->
        # create a CDF

exports.Calculator = Calculator
exports.Distribution = Distribution
exports.Histogram = Histogram
