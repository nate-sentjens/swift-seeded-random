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

// MARK: - SplitMax64

/// A 64-bit pseudo-random number generator using the SplitMix64 algorithm.
///
/// SplitMix64 is a fast, high-quality generator with 64 bits of state. It passes BigCrush
/// and PractRand, and is the recommended method for expanding a single seed into
/// the larger state needed by generators like ``Xoshiro256StarStar``.
///
/// This implementation matches Vigna's reference C implementation exactly.
/// The output sequence for any given seed is frozen and will never change.
///
/// ## Thread safety
/// `SplitMix64` is a value type. Each copy maintains independent state, so
/// concurrent use of distinct copies is safe. A single instance requires
/// exclusive access for mutation (enforced by `mutating` methods),
/// as with any value type.
///
/// ## Quality
/// Passes TestU01 BigCrush and PractRand. Period: 2⁶⁴. Not suitable for
/// cryptographic use.
///
/// > Warning: This is **not** a cryptographic random number generator.
/// > Never use it for security-sensitive purposes.
///
/// ## Reference
/// Sebastiano Vigna, "Further scramblings of Marsaglia's xorshift generators",
/// *Journal of Computational and Applied Mathematics*, 2017.
@frozen
public struct SplitMix64: StableRandomSource {

  // MARK: Lifecycle

  /// Creates a generator seeded with the given value.
  ///
  /// Every `UInt64` value, including zero, is a valid seed.
  ///
  /// - Parameter seed: The seed value.
  @inlinable
  public init(seed: UInt64) {
    _state = seed
  }

  /// Creates a generator restored from a previously saved state.
  ///
  /// Use this to resume a sequence mid-stream after reading ``state``.
  ///
  /// - Parameter state: A state value previously obtained from ``state``.
  @inlinable
  public init(state: UInt64) {
    _state = state
  }

  // MARK: Public

  /// The generator's current 64-bit state.
  ///
  /// Read this property to snapshot the generator for later resumption
  /// via ``init(state:)``.
  public var state: UInt64 { _state }

  /// Advances the state and returns the next 64-bit value.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// ```
  /// state = state &+ 0x9e3779b97f4a7c15
  /// z = state
  /// z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
  /// z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
  /// return z ^ (z >> 31)
  /// ```
  @inlinable
  public mutating func nextUInt64() -> UInt64 {
    _state &+= 0x9e37_79b9_7f4a_7c15

    var z = _state
    z = (z ^ (z >> 30)) &* 0xbf58_476d_1ce4_e5b9
    z = (z ^ (z >> 27)) &* 0x94d0_49bb_1331_11eb

    return z ^ (z >> 31)
  }

  // MARK: Internal

  @usableFromInline
  var _state: UInt64

}
