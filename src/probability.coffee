_ = require './helpers'
math = require './math'
distributions = require './distributions'
fac = math.factorial
pow = math.power

exports.binomial = 
    coefficient: (n, k) ->
        fac(n)/(fac(k)*fac(n-k))
    
    probability: (individual_probability, trials, successes) ->
        p = individual_probability
        n = trials
        k = successes

        co = exports.binomial.coefficient(n,k)
        co * pow(p,k) * pow(1-p,n-k)

    distribution: (probability, trials) ->
        success_range = [0..trials]
        dist = (exports.binomial.probability(probability, trials, i) for i in success_range)

        histogram = distributions.Histogram::empty()

        for key in success_range
            histogram.values[key] = dist[key]
        
        histogram
