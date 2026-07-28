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

@Suite("Xoshiro256StarStar golden vectors")
struct Xoshiro256StarStarGoldenTests {

  @Test("Seed 0 state expansion matches SplitMix64 reference")
  func seed0StateExpansion() {
    let rng = Xoshiro256StarStar(seed: 0)

    #expect(rng.state.0 == 0xe220_a839_7b1d_cdaf)
    #expect(rng.state.1 == 0x6e78_9e6a_a1b9_65f4)
    #expect(rng.state.2 == 0x06c4_5d18_8009_454f)
    #expect(rng.state.3 == 0xf88b_b8a8_724c_81ec)
  }

  @Test("Seed 42 state expansion matches SplitMix64 reference")
  func seed42StateExpansion() {
    let rng = Xoshiro256StarStar(seed: 42)

    #expect(rng.state.0 == 0xbdd7_3226_2feb_6e95)
    #expect(rng.state.1 == 0x28ef_e333_b266_f103)
    #expect(rng.state.2 == 0x4752_6757_130f_9f52)
    #expect(rng.state.3 == 0x581c_e1ff_0e4a_e394)
  }

  @Test("Seed 0 produces expected first 8 outputs")
  func seed0() {
    var rng = Xoshiro256StarStar(seed: 0)

    let expected: [UInt64] = [
      0x99ec_5f36_cb75_f2b4,
      0xbf6e_1f78_4956_452a,
      0x1a5f_849d_4933_e6e0,
      0x6aa5_94f1_262d_2d2c,
      0xbba5_ad4a_1f84_2e59,
      0xffef_8375_d9eb_caca,
      0x6c16_0dee_d2f5_4c98,
      0x8920_ad64_8fc3_0a3f,
    ]

    for value in expected {
      #expect(rng.nextUInt64() == value)
    }
  }

  @Test("Seed 42 produces expected first 8 outputs")
  func seed42() {
    var rng = Xoshiro256StarStar(seed: 42)

    let expected: [UInt64] = [
      0x1578_0b2e_0c2e_c716,
      0x6104_d986_6d11_3a7e,
      0xae17_5332_39e4_99a1,
      0xecb8_ad47_03b3_60a1,
      0xfde6_dc7f_e2ec_5e64,
      0xc50d_a531_0179_5238,
      0xb821_5485_5a65_ddb2,
      0xd99a_2743_ebe6_0087,
    ]

    for value in expected {
      #expect(rng.nextUInt64() == value)
    }
  }

  @Test("State roundtrip preserves sequence")
  func stateRoundtrip() {
    var rng = Xoshiro256StarStar(seed: 12345)
    _ = rng.nextUInt64()
    _ = rng.nextUInt64()

    let savedState = rng.state
    let expected = rng.nextUInt64()

    var restored = Xoshiro256StarStar(state: savedState)
    #expect(restored.nextUInt64() == expected)
  }
}
