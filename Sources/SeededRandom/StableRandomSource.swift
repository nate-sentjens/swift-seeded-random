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

// MARK: - StableRandomSource

/// A pseudo-random number generator with a permanent cross-platform stability guarantee.
///
/// Types conforming to `StableRandomSource` produce deterministic sequences
/// from a given state. All derived operations (bounded integers, Booleans,
/// shuffling, element selection) are defined in terms of ``nextUInt64()``
/// using frozen algorithms.
///
/// ## Stability guarantee
/// Every method provided by the default implementations uses a specific,
/// documented algorithm. These algorithms are frozen: the same generator state
/// will produce identical results on any platform, any Swift version, forever.
/// Golden vector tests in this library's test target enforce this contract.
///
/// ## Standard library interop
/// Conformers also satisfy `RandomNumberGenerator`, so they work with stdlib
/// APIs like `Int.random(in:using:)` and `Array.shuffled(using:)`. However,
/// the stdlib does **not** guarantee its algorithms are stable across Swift
/// versions. Use the methods on this protocol when you need the stability
/// guarantee; use the stdlib APIs when convenience matters more than
/// reproducibility.
///
/// > Warning: Conforming types are **not** cryptographic random number
/// > generators. Never use them for security-sensitive purposes.
public protocol StableRandomSource: RandomNumberGenerator, Sendable, Hashable {

  /// Advances the generator state and returns the next raw 64-bit value.
  ///
  /// This is the fundamental primitive. The output sequence is deterministic
  /// given the same initial state.
  mutating func nextUInt64() -> UInt64
}

// MARK: - RandomNumberGenerator bridge

extension StableRandomSource {

  @inlinable
  public mutating func next() -> UInt64 {
    nextUInt64()
  }
}

// MARK: - Bounded integer (Lemire's nearly-divisionless method)

extension StableRandomSource {

  /// Returns a uniformly distributed random value in `0 ..< upperBound`.
  ///
  /// Uses Lemire's nearly-divisionless method (2019). The algorithm consumes
  /// one call to ``nextUInt64()`` in the common case and rejects with
  /// probability less than 50%.
  ///
  /// - Precondition: `upperBound > 0`.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// ```
  /// x = nextUInt64()
  /// (hi, lo) = x.multipliedFullWidth(by: upperBound)
  /// if lo < upperBound:
  ///     threshold = (0 &- upperBound) % upperBound
  ///     while lo < threshold:
  ///         x = nextUInt64()
  ///         (hi, lo) = x.multipliedFullWidth(by: upperBound)
  /// return hi
  /// ```
  @inlinable
  public mutating func next(upperBound: UInt64) -> UInt64 {
    precondition(upperBound > 0, "upperBound must be greater than zero")

    var x = nextUInt64()
    var m = x.multipliedFullWidth(by: upperBound)

    if m.low < upperBound {
      let threshold = (0 &- upperBound) % upperBound

      while m.low < threshold {
        x = nextUInt64()
        m = x.multipliedFullWidth(by: upperBound)
      }
    }

    return m.high
  }
}

// MARK: - Boolean

extension StableRandomSource {

  /// Returns a random Boolean value.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// Returns `true` when the least significant bit of ``nextUInt64()`` is 1.
  @inlinable
  public mutating func nextBool() -> Bool {
    nextUInt64() & 1 == 1
  }
}

// MARK: - Closed-range integer

extension StableRandomSource {

  /// Returns a uniformly distributed random `Int` within the given range.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// ```
  /// width = UInt64(bitPattern: range.upperBound &- range.lowerBound) &+ 1
  /// if width == 0:          // full Int range requested
  ///     return Int(bitPattern: nextUInt64())
  /// offset = next(upperBound: width)
  /// return range.lowerBound &+ Int(bitPattern: offset)
  /// ```
  @inlinable
  public mutating func next(in range: ClosedRange<Int>) -> Int {
    let width = UInt64(bitPattern: Int64(range.upperBound &- range.lowerBound)) &+ 1

    if width == 0 {
      return Int(truncatingIfNeeded: nextUInt64())
    }

    let offset = next(upperBound: width)
    return range.lowerBound &+ Int(truncatingIfNeeded: offset)
  }
}

// MARK: - Shuffle (Fisher-Yates)

extension StableRandomSource {

  /// Shuffles the collection in place using Fisher-Yates.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// ```
  /// for i in stride(from: count - 1, through: 1, by: -1):
  ///     j = Int(next(upperBound: UInt64(i + 1)))
  ///     swap collection[startIndex + i] with collection[startIndex + j]
  /// ```
  @inlinable
  public mutating func shuffle<C: MutableCollection & RandomAccessCollection>(
    _ collection: inout C
  ) {
    let count = collection.count

    guard count > 1 else {
      return
    }

    for i in stride(from: count - 1, through: 1, by: -1) {
      let j = Int(next(upperBound: UInt64(i + 1)))
      let indexI = collection.index(collection.startIndex, offsetBy: i)
      let indexJ = collection.index(collection.startIndex, offsetBy: j)

      collection.swapAt(indexI, indexJ)
    }
  }
  
  /// Returns a new array with the elements shuffled.
  @inlinable
  public mutating func shuffled<S: Sequence>(_ source: S) -> [S.Element] {
    var array = Array(source)
    shuffle(&array)

    return array
  }
}

// MARK: - Random element selection

extension StableRandomSource {

  /// Returns a random element from the collection, or `nil` if empty.
  ///
  /// ### Algorithm specification (frozen)
  ///
  /// ```
  /// if collection.isEmpty: return nil
  /// index = Int(next(upperBound: UInt64(collection.count)))
  /// return collection[startIndex + index]
  /// ```
  @inlinable
  public mutating func randomElement<C: RandomAccessCollection>(
    of collection: C
  ) -> C.Element? {
    guard !collection.isEmpty else {
      return nil
    }

    let offset = Int(next(upperBound: UInt64(collection.count)))
    return collection[collection.index(collection.startIndex, offsetBy: offset)]
  }
}
