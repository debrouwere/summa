distributions = require '../src/distributions'

d = new distributions.Distribution [1,1,1.5,4,7,9,9.5,10,11,12.5,13,14]
#d2 = new distributions.Distribution [1..100]

#console.log d.values.map (v, i) -> "#{(i+1)/d.values.length} => #{v}"

console.log d
