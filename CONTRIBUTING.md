# Contributing to swift-seeded-random

## The golden-test policy
This package's core value is the **stability contract**: the same seed produces
the same results on every platform, every Swift version.

Golden vector tests in `Tests/SeededRandomTests/` enforce this contract. Each
test contains hardcoded expected values verified against the reference C
implementations. **These fixtures are immutable.**

- Any code change that alters a golden test output is a **semver-major breaking
  change**.
- If a new algorithm or behavior is needed, add a new type or method rather
  than modifying an existing one.
- Never "fix" a golden test by updating its expected values unless you are
  intentionally making a breaking change in a new major version.

## What to contribute
- Bug fixes that do not alter output sequences
- New generator types (with their own golden vectors)
- New derived operations on `StableRandomSource` (with frozen algorithm
  specifications and golden tests)
- Documentation improvements
- Performance improvements that preserve bit-exact output

## Development
```bash
swift build
swift test
swift package generate-documentation
```

Build and test on both macOS and Linux before submitting a pull request. The CI
workflow runs both.

## Code style
- Swift 6 language mode (strict concurrency)
- No Foundation imports
- All public API must have DocC documentation
- Follow Swift API Design Guidelines
