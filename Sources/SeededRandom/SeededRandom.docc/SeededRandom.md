# ``SeededRandom``
Seeded, reproducible pseudo-random number generation with a permanent
cross-platform stability guarantee.

## Overview
Swift's standard library provides no seedable random number generator, and
existing PRNG packages typically stop at `next() -> UInt64`, leaving users to
call `Int.random(in:using:)` or `shuffle(using:)` from the standard library.
The problem: the standard library does not guarantee that its range-mapping or
shuffle algorithms are stable across Swift versions. A seed that produces one
shuffle today may produce a different shuffle after a toolchain update.

`SeededRandom` closes that gap. It provides both the generators as well as
the derived operations (bounded integers, Booleans, shuffles, element
selection), all using frozen, golden-tested algorithms that produce identical
results on any platform and any Swift version.

```swift
import SeededRandom

var rng = SeededRandom(seed: 42)

let roll = rng.next(in: 1...6)
let coinFlip = rng.nextBool()
let deck = rng.shuffled(Array(0..<52))
let pick = rng.randomElement(of: ["red", "green", "blue"])
```

### Standard library interop
Every generator also conforms to Swift's `RandomNumberGenerator`, so you can pass it to stdlib APIs like `Int.random(in:using:)`. However, the standard library does not guarantee algorithm stability&mdash;use the methods on ``StableRandomSource`` when reproducibility matters.

## Topics
### Essentials
- <doc:WhySeededRandomness>
- <doc:TheStabilityContract>
- ``SeededRandom``

### Generators
- ``SplitMix64``
- ``Xoshiro256StarStar``
- <doc:ChoosingAGenerator>

### Protocol
- ``StableRandomSource``
