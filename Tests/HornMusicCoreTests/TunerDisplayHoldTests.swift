import XCTest
@testable import HornMusicCore

final class TunerDisplayHoldTests: XCTestCase {
    private func reading(_ pitch: Float = 349.22824) -> TunerData {
        TunerData.measure(pitch: pitch, amplitude: 1, sensitivity: 0.2, instrumentKey: .F)
    }

    func testFinalReadingRemainsForOnePointFiveSecondsThenClears() {
        var hold = TunerDisplayHold()
        let note = reading(349.22824 * Float(pow(2, 17.0 / 1200)))
        hold.receive(note, state: .running, at: 10)
        hold.receive(TunerData(), state: .running, at: 10.1)
        XCTAssertTrue(hold.isHolding)
        XCTAssertEqual(hold.data.pitch, note.pitch)
        XCTAssertEqual(hold.data.cents, note.cents)
        XCTAssertEqual(hold.data.cents, 17, accuracy: 0.01)
        XCTAssertEqual(hold.data.amplitude, note.amplitude)
        XCTAssertEqual(hold.data.noteNameWithSharps, note.noteNameWithSharps)
        XCTAssertEqual(hold.data.noteNameWithFlats, note.noteNameWithFlats)
        hold.expire(at: 11.499)
        XCTAssertEqual(hold.data.noteNameWithSharps, "C5")
        hold.expire(at: 11.5)
        XCTAssertEqual(hold.data.pitch, 0)
        XCTAssertFalse(hold.isHolding)
        XCTAssertNil(hold.deadline)
    }

    func testSilenceDoesNotExtendTheLastValidDeadline() {
        var hold = TunerDisplayHold()
        hold.receive(reading(), state: .running, at: 0)
        for time in [0.1, 0.5, 1, 1.49] {
            hold.receive(TunerData(), state: .running, at: time)
            XCTAssertEqual(hold.deadline, 1.5)
        }
        hold.receive(TunerData(), state: .running, at: 1.5)
        XCTAssertNil(hold.deadline)
    }

    func testNewNoteReplacesHeldNoteImmediatelyAndOldExpiryCannotClearIt() {
        var hold = TunerDisplayHold()
        hold.receive(reading(), state: .running, at: 0)
        hold.receive(TunerData(), state: .running, at: 0.2)
        let next = reading(391.99542)
        hold.receive(next, state: .running, at: 1)
        XCTAssertEqual(hold.data.noteNameWithSharps, "D5")
        XCTAssertEqual(hold.data.pitch, next.pitch)
        XCTAssertFalse(hold.isHolding)
        hold.expire(at: 1.5)
        XCTAssertEqual(hold.data.pitch, next.pitch)
        hold.expire(at: 2.5)
        XCTAssertEqual(hold.data.pitch, 0)
    }

    func testEveryInactiveStateClearsImmediatelyWithoutHolding() {
        let states: [MicrophoneState] = [.idle, .requestingPermission, .permissionDenied, .inputUnavailable,
            .interrupted, .resumeRequired, .background, .mediaServicesUnavailable, .failed("test")]
        for state in states {
            var hold = TunerDisplayHold()
            hold.receive(reading(), state: .running, at: 0)
            hold.receive(reading(), state: state, at: 0.01)
            XCTAssertEqual(hold.data.pitch, 0)
            XCTAssertNil(hold.deadline)
        }
    }

    func testExplicitResetPreventsOldReadingsAfterRestartAndInvalidClockClears() {
        var hold = TunerDisplayHold()
        hold.receive(reading(), state: .running, at: 0)
        hold.clear()
        hold.receive(TunerData(), state: .running, at: 0.1)
        XCTAssertEqual(hold.data.pitch, 0)
        for time in [Double.nan, .infinity, -1] {
            hold.receive(reading(), state: .running, at: 1)
            hold.receive(reading(), state: .running, at: time)
            XCTAssertNil(hold.deadline)
        }
    }
}
