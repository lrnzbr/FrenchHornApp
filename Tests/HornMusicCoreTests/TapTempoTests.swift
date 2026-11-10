import XCTest
@testable import HornMusicCore

final class TapTempoTests: XCTestCase {
    func testTwoTapsSetTempoAndFurtherTapsResistAnOutlier() {
        var tap = TapTempo()
        XCTAssertNil(tap.tap(at: 0))
        XCTAssertEqual(tap.tap(at: 0.5), 120)
        XCTAssertEqual(tap.tap(at: 1), 120)
        XCTAssertEqual(tap.tap(at: 1.5), 120)
        XCTAssertEqual(tap.tap(at: 2.4), 120)
    }

    func testTempoIsRoundedAndBoundedToTheAudioControllersRange() {
        for (interval, expected) in [(0.2, 208.0), (2.0, 40.0), (0.625, 96.0)] {
            var tap = TapTempo()
            _ = tap.tap(at: 0)
            XCTAssertEqual(tap.tap(at: interval), expected)
        }
    }

    func testLongPauseResetAndInvalidClockValuesDoNotProduceBogusTempo() {
        var tap = TapTempo()
        XCTAssertNil(tap.tap(at: .nan))
        XCTAssertNil(tap.tap(at: .infinity))
        XCTAssertNil(tap.tap(at: -1))
        XCTAssertNil(tap.tap(at: 10))
        XCTAssertEqual(tap.tap(at: 10.5), 120)
        XCTAssertNil(tap.tap(at: 14))
        XCTAssertEqual(tap.tap(at: 15), 60)
        XCTAssertNil(tap.tap(at: 1))
        XCTAssertEqual(tap.tap(at: 1.5), 120)
        tap.reset()
        XCTAssertNil(tap.tap(at: 20))
    }

    func testDoublePressDoesNotMoveTheReferenceTap() {
        var tap = TapTempo()
        _ = tap.tap(at: 0)
        XCTAssertNil(tap.tap(at: 0.05))
        XCTAssertEqual(tap.tap(at: 0.5), 120)
    }
}
