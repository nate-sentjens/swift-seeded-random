# Why Seeded Randomness Is Hard in Swift
Understand the gap in Swift's standard library and existing packages that this
package fills.

## The standard library problem
Swift's `SystemRandomNumberGenerator` is explicitly non-deterministic; there
is no way to seed it. The standard library also provides generic APIs like
`Int.random(in:using:)` and `Array.shuffled(using:)` that accept any
`RandomNumberGenerator`, meaning we *can* plug in a seedable generator.

The catch: the standard library does not guarantee that the algorithms behind
those APIs are stable across Swift versions. The range-mapping method used by
`Int.random(in:using:)` and the shuffle algorithm used by
`Array.shuffled(using:)` are implementation details. Apple and the Swift
project reserve the right to change them. This means a seed that produces one 
shuffle in Swift 5.9 might produce a different shuffle in Swift 6.1.

## Other available packages
Several Swift pseudo-RNG packages exist (`sbooth/DRBGs`, `regexident/PseudoRandom`,
various xoshiro ports). They provide a correct `next() -> UInt64`, but they
stop there. Users then call the stdlib's range-mapping and shuffle APIs,
inheriting the stability problem described above.

## GameplayKit
Apple's `GKRandomSource` and its subclasses provide seedable generators, but
they carry no cross-version bit-stability guarantee. They are also
Apple-platform-only, ruling out Linux.

## What this package guarantees
`SeededRandom` owns every operation in the chain, from the raw generator
output through bounded-integer mapping, Boolean derivation, shuffling, and
element selection. Every algorithm is:

1. **Specified**: documented with pseudocode in the API documentation.
2. **Frozen**: will never change for the lifetime of a given type.
3. **Golden-tested**: verified against hardcoded expected values derived from the reference C implementations.

The same seed produces the same results across Apple platforms, and Linux.
