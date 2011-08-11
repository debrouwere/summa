###
See https://github.com/mbostock/d3/wiki/Arrays for bisection
###

if process?
    module.exports = _ = require 'underscore'
else
    module.exports = _ = window._

_.mixin
    sum: (list) ->
        _.reduce list, ((memo, num) -> memo + num), 0

    invert: (hash) ->
        inverted_hash = {}
        for k, v in hash
            inverted_hash[v] = k
        
        inverted_hash

    bisect: (list, point, cmp) ->
        cmp ?= (a, b) -> a > b
    
        list = _.sortBy list, (a) -> a

        for item, index in list
            if cmp(item, point)
                return index

        return 0

    bisect_left: (list, point) ->
        _.bisect list, point, (a, b) -> a >= b

    items: (hash) ->
        items = []
        for k, v of hash
            items.push [k, v]

        items

    tuples: (hash) ->
        _.items hash

    # a smart partitioning algorithm that makes very
    # evenly divided chunks, instead of overstuffing
    # the last partition
    partition: (list, parts) ->
        list = _.clone(list)
        partitions = []
        # the minimal amount of values that each partition should hold
        n = Math.floor(list.length / parts)
        partitions.push n for i in [1..parts]
        
        extras = list.length % parts

        # increase partition sizes in a round-robin
        i = 0
        while extras > 0
            partitions[i % list.length] += 1
            i++
            extras--

        partitions.map (n) -> list.splice(0, n)
