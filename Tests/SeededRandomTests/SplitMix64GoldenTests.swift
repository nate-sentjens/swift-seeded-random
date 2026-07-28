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

@Suite("SplitMix64 golden vectors")
struct SplitMix64GoldenTests {

  @Test("Seed 0 produces expected first 8 outputs")
  func seed0() {
    var rng = SplitMix64(seed: 0)
    let expected: [UInt64] = [
      0xe220_a839_7b1d_cdaf,
      0x6e78_9e6a_a1b9_65f4,
      0x06c4_5d18_8009_454f,
      0xf88b_b8a8_724c_81ec,
      0x1b39_896a_51a8_749b,
      0x53cb_9f0c_747e_a2ea,
      0x2c82_9abe_1f45_32e1,
      0xc584_133a_c916_ab3c,
    ]
    for value in expected {
      #expect(rng.nextUInt64() == value)
    }
  }

  @Test("Seed 42 produces expected first 8 outputs")
  func seed42() {
    var rng = SplitMix64(seed: 42)
    let expected: [UInt64] = [
      0xbdd7_3226_2feb_6e95,
      0x28ef_e333_b266_f103,
      0x4752_6757_130f_9f52,
      0x581c_e1ff_0e4a_e394,
      0x09bc_585a_2448_23f2,
      0xde44_31fa_3c80_db06,
      0x37e9_671c_4537_6d5d,
      0xccf6_35ee_9e9e_2fa4,
    ]
    for value in expected {
      #expect(rng.nextUInt64() == value)
    }
  }

  @Test("State roundtrip preserves sequence")
  func stateRoundtrip() {
    var rng = SplitMix64(seed: 12345)
    _ = rng.nextUInt64()
    _ = rng.nextUInt64()
    let savedState = rng.state
    let expected = rng.nextUInt64()

    var restored = SplitMix64(state: savedState)
    #expect(restored.nextUInt64() == expected)
  }
}
