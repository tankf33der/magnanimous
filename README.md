I would like to check no [magnanimous](https://oeis.org/A252996) numbers after *97393713331910*
till *2^64* and a little beyond.

Multithread workers handle input range of BigInt's from master and
asks new when done. Primality test implemented via [Miller-Rabin](https://rosettacode.org/wiki/Miller%E2%80%93Rabin_primality_test).
Task inspired by this Rosettacode [task](http://rosettacode.org/wiki/Magnanimous_numbers).
