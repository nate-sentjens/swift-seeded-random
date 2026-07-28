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

import Testing

@testable
import SeededRandom

@Suite("Derived operations: golden vectors")
struct DerivedOperationTests {

  @Test("Bounded integer upperBound=100, seed 42, 10 values")
  func boundedInteger() {
    var rng = Xoshiro256StarStar(seed: 42)

    let expected: [UInt64] = [8, 37, 68, 92, 99, 76, 71, 85, 76, 58]
    let actual = (0..<10).map {
      _ in rng.next(upperBound: 100)
    }

    #expect(actual == expected)
  }

  @Test("Boolean sequence, seed 42, 20 values")
  func booleanSequence() {
    var rng = Xoshiro256StarStar(seed: 42)

    let expected: [Bool] = [
      false, false, true, true, false,
      false, false, true, false, true,
      true, true, false, false, true,
      false, true, false, true, false,
    ]

    let actual = (0..<20).map {
      _ in rng.nextBool()
    }

    #expect(actual == expected)
  }

  @Test("Closed range 1...10, seed 42, 10 values")
  func closedRangeInteger() {
    var rng = Xoshiro256StarStar(seed: 42)

    let expected = [1, 4, 7, 10, 10, 8, 8, 9, 8, 6]
    let actual = (0..<10).map {
      _ in rng.next(in: 1...10)
    }

    #expect(actual == expected)
  }

  @Test("Shuffle of 0..<52 (card deck), seed 42")
  func cardDeckShuffle() {
    var rng = Xoshiro256StarStar(seed: 42)

    let expected = [
      40, 1, 51, 35, 31, 3, 18, 21, 42, 37, 7, 20, 46,
      6, 0, 16, 44, 14, 43, 41, 26, 9, 30, 15, 50, 10,
      49, 8, 17, 13, 5, 2, 23, 24, 29, 22, 39, 27, 12,
      32, 11, 28, 25, 48, 38, 33, 36, 47, 45, 34, 19, 4,
    ]

    let actual = rng.shuffled(Array(0..<52))
    #expect(actual == expected)
  }

  @Test("Shuffle of 0..<100, seed 42")
  func hundredElementShuffle() {
    var rng = Xoshiro256StarStar(seed: 42)

    let expected = [
      0, 47, 31, 56, 69, 26, 40, 3, 12, 35,
      55, 93, 10, 86, 83, 75, 18, 11, 24, 92,
      19, 39, 71, 5, 98, 60, 64, 20, 13, 22,
      4, 78, 17, 77, 54, 62, 52, 99, 84, 38,
      43, 21, 33, 49, 82, 1, 65, 9, 15, 88,
      68, 44, 85, 30, 6, 97, 72, 76, 41, 32,
      59, 94, 2, 50, 48, 90, 63, 81, 42, 28,
      16, 45, 80, 29, 36, 23, 46, 34, 14, 7,
      57, 58, 87, 51, 74, 96, 27, 91, 25, 61,
      53, 70, 79, 67, 73, 95, 89, 66, 37, 8,
    ]

    let actual = rng.shuffled(Array(0..<100))
    #expect(actual == expected)
  }

  @Test("Random element from 5-element array, seed 42, 5 picks")
  func randomElementSelection() {
    var rng = Xoshiro256StarStar(seed: 42)

    let source = ["alpha", "beta", "gamma", "delta", "epsilon"]
    let expected = ["alpha", "beta", "delta", "epsilon", "epsilon"]
    let actual = (0..<5).map {
      _ in rng.randomElement(of: source)!
    }

    #expect(actual == expected)
  }

  @Test("randomElement of empty collection returns nil")
  func randomElementEmpty() {
    var rng = Xoshiro256StarStar(seed: 42)

    let result = rng.randomElement(of: [Int]())
    #expect(result == nil)
  }

  @Test("Bounded with upperBound=1 always returns 0")
  func boundedUpperBound1() {
    var rng = Xoshiro256StarStar(seed: 42)

    for _ in 0..<100 {
      #expect(rng.next(upperBound: 1) == 0)
    }
  }

  @Test("Full Int range does not trap")
  func fullIntRange() {
    var rng = Xoshiro256StarStar(seed: 42)

    let value = rng.next(in: Int.min...Int.max)
    _ = value
  }
}
