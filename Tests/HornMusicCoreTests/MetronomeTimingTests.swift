import XCTest
@testable import HornMusicCore

final class MetronomeTimingTests: XCTestCase {
    private func settings(_ bpm: Double = 120, _ meter: MetronomeMeter = .fourFour, accent: Bool = true) -> MetronomeSettings {
        MetronomeSettings(bpm: bpm, meter: meter, accentFirstBeat: accent)!
    }

    func testSupportedTemposAndInvalidValues() {
        for bpm in [40.0, 120, 208] { XCTAssertNotNil(MetronomeSettings(bpm: bpm, meter: .fourFour, accentFirstBeat: true)) }
        for bpm in [0.0, -1, 39, 209, .nan, .infinity] {
            XCTAssertNil(MetronomeSettings(bpm: bpm, meter: .fourFour, accentFirstBeat: true))
        }
        for rate in [0.0, -1, .nan, .infinity, .greatestFiniteMagnitude] {
            XCTAssertNil(MetronomeClock(sampleRate: rate, settings: settings()))
            XCTAssertNil(MetronomeRenderKernel(sampleRate: rate, settings: settings()))
        }
    }

    func testFractionalBeatIntervalsDoNotAccumulateRoundingDrift() {
        for rate in [44_100.0, 48_000, 96_000] {
            let period = rate * 60 / 137
            var clock = MetronomeClock(sampleRate: rate, settings: settings(137))!
            var beatCount = 0
            for frame in 0...Int(ceil(period * 256)) {
                if clock.nextFrame() != nil {
                    let ideal = Double(beatCount) * period
                    XCTAssertGreaterThanOrEqual(Double(frame) - ideal, -0.00001)
                    XCTAssertLessThanOrEqual(Double(frame) - ideal, 1.00001)
                    beatCount += 1
                }
            }
            XCTAssertEqual(beatCount, 257)
        }
    }

    func testTempoChangePreservesTheCurrentBeatPhase() {
        for newBPM in [40.0, 60, 208] {
            var clock = MetronomeClock(sampleRate: 48_000, settings: settings())!
            for _ in 0..<12_000 { _ = clock.nextFrame() }
            clock.update(settings(newBPM))
            let expectedRemaining = 0.5 * 48_000 * 60 / newBPM
            var nextBeat: Int?
            for frame in 0...Int(ceil(expectedRemaining)) {
                if clock.nextFrame() != nil { nextBeat = frame; break }
            }
            XCTAssertNotNil(nextBeat)
            XCTAssertEqual(Double(nextBeat!), expectedRemaining, accuracy: 1)
        }
    }

    func testRepeatedSettingUpdatesDoNotRestartTheBeat() {
        var clock = MetronomeClock(sampleRate: 8_000, settings: settings())!
        var beats: [Int] = []
        for frame in 0...8_000 {
            clock.update(settings())
            if clock.nextFrame() != nil { beats.append(frame) }
        }
        XCTAssertEqual(beats, [0, 4_000, 8_000])
    }

    func testEveryMeterAccentsOnlyTheFirstClickOfEachBar() {
        for meter in MetronomeMeter.allCases {
            var clock = MetronomeClock(sampleRate: 8_000, settings: settings(120, meter))!
            var beats: [MetronomeBeat] = []
            for _ in 0..<(meter.beatsPerBar * 2 * 4_000) {
                if let beat = clock.nextFrame() { beats.append(beat) }
            }
            XCTAssertEqual(beats.map(\.indexInBar), Array(0..<meter.beatsPerBar) + Array(0..<meter.beatsPerBar))
            XCTAssertEqual(beats.filter(\.accented).count, 2)
        }
        XCTAssertEqual(MetronomeMeter.sixEight.beatUnit, "eighth note")
        XCTAssertEqual(MetronomeMeter.sixEight.beatsPerBar, 6)
    }

    func testMeterChangeBeginsANewBarAtTheNextClick() {
        var clock = MetronomeClock(sampleRate: 8_000, settings: settings())!
        for _ in 0..<6_000 { _ = clock.nextFrame() }
        clock.update(settings(120, .threeFour))
        for _ in 0..<2_000 { XCTAssertNil(clock.nextFrame()) }
        XCTAssertEqual(clock.nextFrame(), MetronomeBeat(indexInBar: 0, accented: true))
    }

    func testDisablingAccentDoesNotResetTimingOrBarPosition() {
        var clock = MetronomeClock(sampleRate: 8_000, settings: settings())!
        for _ in 0..<6_000 { _ = clock.nextFrame() }
        clock.update(settings(accent: false))
        for _ in 0..<2_000 { XCTAssertNil(clock.nextFrame()) }
        XCTAssertEqual(clock.nextFrame(), MetronomeBeat(indexInBar: 2, accented: false))
        for _ in 0..<(4_000 * 5) {
            if let beat = clock.nextFrame() { XCTAssertFalse(beat.accented) }
        }
    }

    func testClickKernelIsFiniteAndSilentBetweenClicks() {
        var kernel = MetronomeRenderKernel(sampleRate: 48_000, settings: settings())!
        var peak: Float = 0
        for frame in 0..<24_000 {
            let sample = kernel.nextSample()
            XCTAssertTrue(sample.isFinite)
            peak = max(peak, abs(sample))
            if frame >= 2_640 { XCTAssertEqual(sample, 0) }
        }
        XCTAssertGreaterThan(peak, 0.5)
        XCTAssertLessThanOrEqual(peak, 0.88)
    }

    private final class FakeOutput: MetronomeOutput {
        var starts = 0
        var stops = 0
        var updates: [MetronomeSettings] = []
        var startError: Error?
        var failure: ((String) -> Void)?
        func start(settings: MetronomeSettings, failure: @escaping (String) -> Void) throws {
            starts += 1
            self.failure = failure
            if let error = startError { throw error }
        }
        func update(settings: MetronomeSettings) { updates.append(settings) }
        func stop() { stops += 1 }
    }

    func testStartAndStopAreIdempotentAndRestartUsesOneOutput() {
        let output = FakeOutput()
        let playback = MetronomePlayback(output: output)
        playback.start(settings: settings())
        playback.start(settings: settings())
        XCTAssertEqual(output.starts, 1)
        playback.stop()
        playback.stop()
        XCTAssertEqual(output.stops, 1)
        XCTAssertEqual(playback.state, .stopped)
        playback.start(settings: settings(208))
        XCTAssertEqual(output.starts, 2)
        XCTAssertEqual(playback.state, .playing)
    }

    func testLiveSettingsReachOutputWithoutRestarting() {
        let output = FakeOutput()
        let playback = MetronomePlayback(output: output)
        playback.start(settings: settings())
        let changed = settings(208, .sixEight, accent: false)
        playback.update(settings: changed)
        XCTAssertEqual(output.updates, [changed])
        XCTAssertEqual(output.starts, 1)
        XCTAssertEqual(output.stops, 0)
        playback.stop()
        playback.update(settings: settings(40))
        XCTAssertEqual(output.updates, [changed])
    }

    func testFailedStartupCleansUpAndCanBeRetried() {
        let output = FakeOutput()
        output.startError = NSError(domain: "TestAudio", code: 1)
        let playback = MetronomePlayback(output: output)
        playback.start(settings: settings())
        if case .failed = playback.state {} else { XCTFail("Expected startup failure") }
        XCTAssertEqual(output.stops, 1)
        output.startError = nil
        playback.start(settings: settings())
        XCTAssertEqual(playback.state, .playing)
    }

    func testLateFailureFromAnOldOutputCannotStopNewPlayback() {
        let output = FakeOutput()
        let playback = MetronomePlayback(output: output)
        playback.start(settings: settings())
        let oldFailure = output.failure
        playback.stop()
        playback.start(settings: settings())
        oldFailure?("Old output stopped")
        XCTAssertEqual(playback.state, .playing)
        output.failure?("Output changed")
        XCTAssertEqual(playback.state, .failed("Output changed"))
        XCTAssertEqual(output.stops, 2)
    }
}
