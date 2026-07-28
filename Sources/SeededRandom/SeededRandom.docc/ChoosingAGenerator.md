# Choosing a Generator
Compare the available generators and pick the right one for your use case.

## Overview
This package provides two generators. Both carry the full stability guarantee.
If you don't want to choose, use ``SeededRandom``, which wraps the recommended
default.

## SplitMix64
``SplitMix64`` has 64 bits of state and a period of 2⁶⁴.

**Strengths:**
- Smallest possible state (a single `UInt64`).
- Very fast: one increment and three multiply-xorshift rounds.
- Passes BigCrush and PractRand.
- Ideal for seeding other generators (used internally by
  ``Xoshiro256StarStar/init(seed:)``).

**When to use it:**
- You need a minimal, fast generator and 2⁶⁴ period is sufficient.
- You are generating a small number of values per seed (test fixtures,
  simple procedural content).
- You need to expand a single seed into multiple independent values.

**When not to use it:**
- You need a very long period (simulations drawing billions of values).
- You need to run many parallel streams without risk of overlap.

## Xoshiro256StarStar
``Xoshiro256StarStar`` has 256 bits of state and a period of 2²⁵⁶ − 1.

**Strengths:**
- Extremely long period: effectively inexhaustible.
- Excellent statistical quality; passes BigCrush and PractRand.
- Fast: comparable to SplitMix64 in throughput.
- Large state space makes accidental stream correlation negligible.

**When to use it:**
- General-purpose default for any application.
- Simulations, Monte Carlo methods, or any scenario drawing many values.
- Procedural generation where seeds are shared artifacts.

This is the generator backing ``SeededRandom``.

## The SeededRandom convenience
If you don't have a reason to choose a specific algorithm, use
``SeededRandom``. It wraps ``Xoshiro256StarStar`` and provides the same
stability guarantee. The backing algorithm is documented and frozen for
the lifetime of this major version.

```swift
var rng = SeededRandom(seed: 42)
let value = rng.next(in: 1...100)
```

The named generator types (``SplitMix64``, ``Xoshiro256StarStar``) carry
their own independent stability guarantees that persist even if a future
major version changes the default backing ``SeededRandom``.
