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

// MARK: - Xoshiro256StarStar

/// A 256-bit pseudo-random number generator using the xoshiro256\*\* algorithm.
///
/// Xoshiro256\*\* is an all-purpose, high-quality generator with a period of
/// 2²⁵⁶ − 1 and 256 bits of state. It's the recommended general-purpose
/// generator in this package and the algorithm backing ``SeededRandom``.
///
/// This implementation matches Blackman and Vigna's reference C implementation
/// exactly. The output sequence for any given state is frozen and will never
/// change.
///
/// ## Seeding
/// When initialized from a single `UInt64` seed via ``init(seed:)``, the four
/// state words are expanded using four consecutive calls to
/// ``SplitMix64/nextUInt64()``. This matches Vigna's recommended seeding
/// procedure.
///
/// ## All-zero state
/// The all-zero state `(0, 0, 0, 0)` is an absorbing fixed point (the
/// generator would produce only zeros forever). Both initializers reject it
/// with a precondition failure. When seeding from a `UInt64` via
/// ``init(seed:)``, SplitMix64 expansion guarantees the resulting state is
/// never all-zero.
///
/// ## Thread safety
/// `Xoshiro256StarStar` is a value type. Each copy maintains independent
/// state, so concurrent use of distinct copies is safe. A single instance
/// requires exclusive access for mutation (enforced by `mutating`
/// methods), as with any value type.
///
/// ## Quality
/// Passes TestU01 BigCrush and PractRand. Period: 2²⁵⁶ − 1. Not suitable
/// for cryptographic use.
///
/// > Warning: This is **not** a cryptographic random number generator.
/// > Never use it for security-sensitive purposes.
///
/// ## Reference
///
/// David Blackman and Sebastiano Vigna, "Scrambled Linear Pseudorandom Number
/// Generators", *ACM Transactions on Mathematical Software*, 2021.
@frozen
public struct Xoshiro256StarStar: StableRandomSource {

  // MARK: Lifecycle

  /// Creates a generator by expanding a single seed into 256 bits of state.
  ///
  /// Uses four consecutive calls to ``SplitMix64/nextUInt64()`` to fill the
  /// state, following Vigna's recommendation. The expansion is frozen and
  /// will produce identical state for the same seed forever.
  ///
  /// Every `UInt64` value, including zero, is a valid seed.
  ///
  /// - Parameter seed: The seed value.
  @inlinable
  public init(seed: UInt64) {
    var sm = SplitMix64(seed: seed)

    _state = (sm.nextUInt64(), sm.nextUInt64(), sm.nextUInt64(), sm.nextUInt64())
  }

  /// Creates a generator from explicit state words.
  ///
  /// Use this to resume a sequence mid-stream after reading ``state``.
  ///
  /// - Precondition: At least one state word must be non-zero. The all-zero
  ///   state is an absorbing fixed point.
  /// - Parameter state: A four-word state tuple, typically obtained from a
  ///   previous read of ``state``.
  @inlinable
  public init(state: (UInt64, UInt64, UInt64, UInt64)) {
    precondition(
      (state.0 | state.1 | state.2 | state.3) != 0,
      "Xoshiro256StarStar state must not be all zeros")

    _state = state
  }

  // MARK: Public

  /// The generator's four-word state.
  ///
  /// Read this property to snapshot the generator for later resumption via ``init(state:)``.
  public var state: (UInt64, UInt64, UInt64, UInt64) { _state }

  /// Advances the state and returns the next 64-bit value.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// ```
  /// result = rotl(s1 * 5, 7) * 9
  /// t = s1 << 17
  /// s2 ^= s0;  s3 ^= s1;  s1 ^= s2;  s0 ^= s3
  /// s2 ^= t
  /// s3 = rotl(s3, 45)
  /// return result
  /// ```
  ///
  /// where `rotl(x, k) = (x << k) | (x >> (64 - k))`.
  @inlinable
  public mutating func nextUInt64() -> UInt64 {
    let result = rotl(_state.1 &* 5, 7) &* 9

    let t = _state.1 << 17

    _state.2 ^= _state.0
    _state.3 ^= _state.1
    _state.1 ^= _state.2
    _state.0 ^= _state.3

    _state.2 ^= t
    _state.3 = rotl(_state.3, 45)

    return result
  }

  @inlinable
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs._state.0 == rhs._state.0
      && lhs._state.1 == rhs._state.1
      && lhs._state.2 == rhs._state.2
      && lhs._state.3 == rhs._state.3
  }

  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(_state.0)
    hasher.combine(_state.1)
    hasher.combine(_state.2)
    hasher.combine(_state.3)
  }

  // MARK: Internal

  @usableFromInline
  var _state: (UInt64, UInt64, UInt64, UInt64)

}

@inlinable @inline(__always)
func rotl(_ x: UInt64, _ k: Int) -> UInt64 {
  (x << k) | (x >> (64 - k))
}
