# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0]

### Added
- `StableRandomSource` protocol with frozen derived operations (Lemire bounded mapping, Fisher-Yates shuffle, Boolean, closed-range integer, random element selection).
- `SplitMix64` generator matching Vigna's reference implementation.
- `Xoshiro256StarStar` generator matching Blackman-Vigna's reference implementation, seeded via SplitMix64 expansion.
- `SeededRandom` convenience wrapper backed by Xoshiro256StarStar.
- Golden vector tests for raw generator output and all derived operations.
- DocC documentation catalog with articles on the stability contract, generator selection, and the Swift standard library gap.
