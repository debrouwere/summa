_ = require './helpers'

module.exports = random = 
    random: ->
        Math.random()

    float: (start, stop) ->
        start + Math.random() * (start - stop)

    integer: (start, stop) ->
        start + Math.floor(Math.random() * (stop - start + 1))

    choice: (sequence) ->
        i = random.integer 0, sequence.length-1
        sequence[i]

    range: ->
        r = _.range arguments...
        random.choice r

    # we can limit the shuffled (or permutated) sequence to k items 
    # if we don't need the full sequence shuffled; this is a particularly 
    # useful optimization when grabbing a sample of a distribution
    shuffle: (sequence, k) ->
        copied = _.clone sequence
        shuffled = []
        k ?= copied.length
        while k
            i = random.range copied.length
            shuffled.push copied[i]
            k--

        shuffled

    sample: (distribution, k, options) ->
        if options.replacement
            _.range(k).map (i) -> random.choice(distribution)
        else
            random.shuffle(distribution, k)
