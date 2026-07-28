# SeededRandom
[![CI](https://github.com/nate-sentjens/swift-seeded-random/actions/workflows/ci.yml/badge.svg)](https://github.com/nate-sentjens/swift-seeded-random/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnate-sentjens%2Fswift-seeded-random%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nate-sentjens/swift-seeded-random) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnate-sentjens%2Fswift-seeded-random%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nate-sentjens/swift-seeded-random)

Seeded pseudo-random number generation for Swift with a cross-platform stability guarantee. The same seed produces the same results on any platform and any Swift version.

## Usage
```swift
import SeededRandom

var rng = SeededRandom(seed: 42)

let roll = rng.next(in: 1...6)
let coin = rng.nextBool()
let deck = rng.shuffled(Array(0..<52))
let pick = rng.randomElement(of: items)
```

All derived operations (bounded integers, Booleans, shuffles, element selection) use frozen, golden-tested algorithms owned by this package (instead of the Swift standard library's, which [may change between Swift versions](https://github.com/swiftlang/swift/blob/main/stdlib/public/core/CollectionAlgorithms.swift#L545-L551)).

### Swift standard library interop
Every generator also conforms to `RandomNumberGenerator`, providing for its use in Swift's random `using:` APIs:

```swift
var rng = SeededRandom(seed: 42)

let n = Int.random(in: 1...100, using: &rng)
let shuffled = myArray.shuffled(using: &rng)
let element = myArray.randomElement(using: &rng)
```

The `using:` parameter drives where the random bits come from, but the standard library applies its own mapping algorithms on top&mdash;e.g., how it converts a raw `UInt64` into a bounded integer, or which swap order it uses for shuffling. Those algorithms [may change between Swift versions](https://github.com/swiftlang/swift/blob/main/stdlib/public/core/CollectionAlgorithms.swift#L545-L551), meaning the same seed can produce different results after a toolchain update. Use the package's own methods when reproducibility matters.

## Installation
```swift
dependencies: [
  .package(url: "https://github.com/nate-sentjens/swift-seeded-random.git", from: "0.1.0"),
]
```

## Generators
| Type | State | Period | Notes |
|---|---|---|---|
| `SeededRandom` | 256 bits | 2²⁵⁶ − 1 | Recommended default (wraps `Xoshiro256StarStar`) |
| `Xoshiro256StarStar` | 256 bits | 2²⁵⁶ − 1 | General-purpose usage |
| `SplitMix64` | 64 bits | 2⁶⁴ | Minimal state, seed expansion |

All conform to both `StableRandomSource` (stability-guaranteed operations) and `RandomNumberGenerator` (standard library interop).

## Documentation
See the [DocC documentation](https://swiftpackageindex.com/nate-sentjens/swift-seeded-random/documentation/seededrandom) for the full stability contract, algorithm specifications, and generator comparison.
