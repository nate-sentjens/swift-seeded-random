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

@Suite("Stability contract")
struct StabilityContractTests {

  @Test("Same seed always produces same sequence")
  func determinism() {
    var rng1 = Xoshiro256StarStar(seed: 99)
    var rng2 = Xoshiro256StarStar(seed: 99)

    for _ in 0..<1000 {
      #expect(rng1.nextUInt64() == rng2.nextUInt64())
    }
  }

  @Test("SeededRandom matches underlying Xoshiro256StarStar")
  func seededRandomMatchesXoshiro() {
    var sr = SeededRandom(seed: 7)
    var xo = Xoshiro256StarStar(seed: 7)

    for _ in 0..<100 {
      #expect(sr.nextUInt64() == xo.nextUInt64())
    }
  }

  @Test("Copy does not share state")
  func valueSemantics() {
    var original = Xoshiro256StarStar(seed: 1)
    var copy = original

    #expect(original.nextUInt64() == copy.nextUInt64())
    #expect(original.nextUInt64() == copy.nextUInt64())
  }

  @Test("Generators are Sendable")
  func sendable() async {
    let rng = Xoshiro256StarStar(seed: 42)
    let value = await Task {
      var local = rng
      return local.nextUInt64()
    }.value

    var check = Xoshiro256StarStar(seed: 42)
    #expect(value == check.nextUInt64())
  }

  @Test("SplitMix64 is Hashable")
  func splitMixHashable() {
    let a = SplitMix64(seed: 1)
    let b = SplitMix64(seed: 1)
    let c = SplitMix64(seed: 2)

    #expect(a == b)
    #expect(a != c)
    #expect(a.hashValue == b.hashValue)
  }

  @Test("Xoshiro256StarStar is Hashable")
  func xoshiroHashable() {
    let a = Xoshiro256StarStar(seed: 1)
    let b = Xoshiro256StarStar(seed: 1)
    let c = Xoshiro256StarStar(seed: 2)

    #expect(a == b)
    #expect(a != c)
    #expect(a.hashValue == b.hashValue)
  }

  @Test("SplitMix64 works via RandomNumberGenerator")
  func splitmixStdlibInterop() {
    var rng = SplitMix64(seed: 42)

    let value = Int.random(in: 0..<100, using: &rng)
    #expect((0..<100).contains(value))
  }

  @Test("Xoshiro256StarStar works via RandomNumberGenerator")
  func xoshiroStdlibInterop() {
    var rng = Xoshiro256StarStar(seed: 42)

    let value = Int.random(in: 0..<100, using: &rng)
    #expect((0..<100).contains(value))
  }
}
