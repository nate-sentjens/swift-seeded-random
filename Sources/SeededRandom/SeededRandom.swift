// MIT License
//
// Copyright (c) 2026 Nate Sentjens
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// MARK: - SeededRandom

/// A seeded pseudo-random number generator with a cross-platform stability guarantee.
///
/// `SeededRandom` is the recommended entry point when you don't need to choose
/// a specific algorithm. It wraps ``Xoshiro256StarStar``, providing a 256-bit
/// state and a period of 2²⁵⁶ − 1.
///
/// ```swift
/// var rng = SeededRandom(seed: 42)
/// let value = rng.next(in: 1...100)
/// let shuffled = rng.shuffled(Array(0..<52))
/// ```
///
/// > Note: The backing algorithm is ``Xoshiro256StarStar``. This choice is
/// > documented and frozen for the lifetime of this major version. The named
/// > generator types (``SplitMix64``, ``Xoshiro256StarStar``) carry their own
/// > permanent stability guarantees independent of this wrapper.
///
/// ## Thread safety
/// `SeededRandom` is a value type. Each copy maintains independent state, so
/// concurrent use of distinct copies is safe. A single instance requires
/// exclusive access for mutation (enforced by `mutating` methods),
/// as with any value type.
///
/// ## Quality
/// Backed by ``Xoshiro256StarStar``, which passes TestU01 BigCrush and
/// PractRand. Period: 2²⁵⁶ − 1. Not suitable for cryptographic use.
///
/// > Warning: This is **not** a cryptographic random number generator.
/// > Never use it for security-sensitive purposes.
@frozen
public struct SeededRandom: StableRandomSource {

  // MARK: Lifecycle

  /// Creates a generator seeded with the given value.
  ///
  /// - Parameter seed: The seed value. Every `UInt64` value is valid.
  @inlinable
  public init(seed: UInt64) {
    _generator = Xoshiro256StarStar(seed: seed)
  }

  /// Creates a generator wrapping an existing ``Xoshiro256StarStar``.
  ///
  /// - Parameter generator: The generator to wrap.
  @inlinable
  public init(_ generator: Xoshiro256StarStar) {
    _generator = generator
  }

  // MARK: Public

  /// The underlying generator.
  public var generator: Xoshiro256StarStar { _generator }

  @inlinable
  public mutating func nextUInt64() -> UInt64 {
    _generator.nextUInt64()
  }

  // MARK: Internal

  @usableFromInline
  var _generator: Xoshiro256StarStar

}
