# The Stability Contract
Understand exactly what is frozen, how it is enforced, and the important
distinction between the package's operations and the standard library's.

## What is frozen
Every public operation on ``StableRandomSource`` uses a specific, named
algorithm. These algorithms will never change for the lifetime of the type
that implements them:

| Operation | Algorithm |
|---|---|
| ``SplitMix64/nextUInt64()`` | Vigna's SplitMix64 reference |
| ``Xoshiro256StarStar/nextUInt64()`` | Blackman-Vigna xoshiro256\*\* reference |
| ``Xoshiro256StarStar/init(seed:)`` | 4× SplitMix64 expansion |
| ``StableRandomSource/next(upperBound:)`` | Lemire's nearly-divisionless method |
| ``StableRandomSource/nextBool()`` | Least significant bit of ``StableRandomSource/nextUInt64()`` |
| ``StableRandomSource/next(in:)`` | Width via wrapping arithmetic, then ``StableRandomSource/next(upperBound:)`` |
| ``StableRandomSource/shuffle(_:)`` | Fisher-Yates (high-to-low), ``StableRandomSource/next(upperBound:)`` per step |
| ``StableRandomSource/randomElement(of:)`` | ``StableRandomSource/next(upperBound:)`` with collection count |

The pseudocode for each algorithm is documented on its method.

## How it is enforced
The test suite contains **golden vector tests**: hardcoded expected values
for every operation, computed from the reference C implementations by
Vigna and Blackman. These fixtures are immutable&mdash;any code change that
alters a golden output is a semver-major breaking change.

If a new algorithm or behavior is needed, it is added as a new method or
type, never as a modification to an existing one.

## The standard library interop caveat
Every generator conforms to Swift's `RandomNumberGenerator`, so you can
write:

```swift
var rng = SeededRandom(seed: 42)
let value = Int.random(in: 1...100, using: &rng)
```

This works, but `Int.random(in:using:)` uses the **standard library's**
range-mapping algorithm, which is not covered by this package's stability
guarantee. If you need reproducible results, use the package's own methods:

```swift
var rng = SeededRandom(seed: 42)
let value = rng.next(in: 1...100)  // stability-guaranteed
```

The same applies to `Array.shuffled(using:)` vs. ``StableRandomSource/shuffled(_:)``,
and `Collection.randomElement(using:)` vs. ``StableRandomSource/randomElement(of:)``.

## All-zero state policy
``Xoshiro256StarStar`` rejects the all-zero state `(0, 0, 0, 0)` with a
precondition failure. The all-zero state is an absorbing fixed point (the
generator would produce only zeros forever). This rejection is a frozen
behavior: it will never be changed to silent remapping or any other
handling.

When seeding from a `UInt64` via ``Xoshiro256StarStar/init(seed:)``,
SplitMix64 expansion guarantees the resulting state is never all-zero, so
this precondition cannot be triggered through normal seeding.
