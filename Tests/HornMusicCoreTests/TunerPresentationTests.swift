import XCTest
@testable import HornMusicCore

final class TunerPresentationTests: XCTestCase {
    func testEveryInactiveStateHidesStalePitchAndNeedle() {
        let data = TunerData.measure(pitch: 440, amplitude: 1, sensitivity: 0.2, instrumentKey: .F)
        let states: [MicrophoneState] = [.idle, .requestingPermission, .permissionDenied, .inputUnavailable,
            .interrupted, .resumeRequired, .background, .mediaServicesUnavailable, .failed("test")]
        for state in states {
            let view = TunerPresentation(data: data, state: state, instrumentKey: .F)
            XCTAssertNil(view.writtenNote)
            XCTAssertNil(view.soundingNote)
            XCTAssertNil(view.frequency)
            XCTAssertNil(view.needlePosition)
            XCTAssertEqual(view.direction, .waiting)
        }
    }

    func testMeterUsesTheSamePitchAndCentsTargetForEveryConfiguration() {
        for instrument in instruments {
            for cents in [-49.9, -12, -1, 0, 1, 12, 49.9] {
                let pitch = Float(440 * pow(2, cents / 1200))
                let data = TunerData.measure(pitch: pitch, amplitude: 1, sensitivity: 0.2, instrumentKey: instrument.key)
                let view = TunerPresentation(data: data, state: .running, instrumentKey: instrument.key)
                XCTAssertEqual(view.writtenNote?.pitch, Pitch(Int8(69 - instrument.key.soundingSemitoneOffset)))
                XCTAssertEqual(view.soundingNote, A4)
                XCTAssertEqual(view.reading!.cents, Double(data.cents), accuracy: 0.00001)
                XCTAssertEqual(view.needlePosition!, cents / 50, accuracy: 0.0001)
                XCTAssertEqual(view.direction, abs(cents) <= 2 ? .inTune : cents < 0 ? .flat : .sharp)
            }
        }
    }

    func testSilenceAndInvalidInputHaveNoReadingEvenWhileCaptureIsRunning() {
        for pitch: Float in [0, -.infinity, .infinity, .nan, -440] {
            let view = TunerPresentation(data: TunerData(pitch: pitch), state: .running, instrumentKey: .F)
            XCTAssertNil(view.reading)
            XCTAssertNil(view.needlePosition)
        }
    }

    func testDirectionAndMeterShareTheTwoCentInTuneBoundary() {
        XCTAssertEqual(TunerPresentation.inTuneThresholdCents, 2)
        for cents in [-2.01, -1.99, 1.99, 2.01] {
            let data = TunerData.measure(pitch: Float(440 * pow(2, cents / 1200)), amplitude: 1,
                                         sensitivity: 0.2, instrumentKey: .F)
            let view = TunerPresentation(data: data, state: .running, instrumentKey: .F)
            let insideBand = abs(view.needlePosition!) <= TunerPresentation.inTuneThresholdCents / 50
            XCTAssertEqual(insideBand, view.direction == .inTune)
            XCTAssertEqual(insideBand, abs(cents) < 2)
        }
    }
}
