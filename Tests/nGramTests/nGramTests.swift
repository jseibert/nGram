import XCTest
@testable import nGram

final class nGramTests: XCTestCase {
    func testBasicNGrams() throws {
        let grams = NGram.collect("2011 Calon Segur")
        XCTAssertEqual(grams.count, 6)
    }

    func testComplicatedNGrams() throws {
        let grams = NGram.collect("1979 Petaluma - Coonawarra Proprietary Red (shiraz/cab Blend) (750ml)")
        XCTAssertEqual(grams.count, 14)
    }

    func testPathologicalNGrams() throws {
        let grams = NGram.collect("Palmer & Co. Blanc de Blancs Champagne 1985 (Champagne, France) -Joe- [RP 92] [WS 91] [JS 91] 2011")
        XCTAssertEqual(grams.count, 49)
    }
}
