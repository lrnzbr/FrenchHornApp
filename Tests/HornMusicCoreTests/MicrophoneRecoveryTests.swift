import XCTest
@testable import HornMusicCore

final class MicrophoneRecoveryTests: XCTestCase {
    private final class FakeInput: MicrophoneInput {
        var permission: MicrophonePermission = .undetermined
        var permissionRequests = 0
        var startCount = 0
        var stopCount = 0
        var startError: Error?
        var completion: (() -> Void)?
        var measurement: ((Float, Float) -> Void)?

        func requestPermission(_ completion: @escaping () -> Void) {
            permissionRequests += 1
            self.completion = completion
        }
        func start(measurement: @escaping (Float, Float) -> Void) throws {
            startCount += 1
            self.measurement = measurement
            if let error = startError { throw error }
        }
        func stop() { stopCount += 1 }
        func answer(_ granted: Bool) {
            permission = granted ? .granted : .denied
            let callback = completion
            completion = nil
            callback?()
        }
    }

    func testConstructionDoesNotRequestPermissionOrStartInput() {
        let input = FakeInput()
        let recovery = MicrophoneRecovery(input: input)
        XCTAssertEqual(recovery.state, .idle)
        XCTAssertEqual(input.permissionRequests, 0)
        XCTAssertEqual(input.startCount, 0)
    }

    func testPermissionRequestedOnceAndGrantedWhileStillVisible() {
        let input = FakeInput()
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.start(for: .settings)
        recovery.setForeground(true)
        XCTAssertEqual(input.permissionRequests, 1)
        XCTAssertEqual(recovery.state, .requestingPermission)
        XCTAssertEqual(input.startCount, 0)
        input.answer(true)
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 1)
    }

    func testDeniedPermissionNeverBuildsGraphOrRepeatsPrompt() {
        let input = FakeInput()
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        input.answer(false)
        recovery.retry()
        recovery.routeChanged()
        XCTAssertEqual(recovery.state, .permissionDenied)
        XCTAssertEqual(input.startCount, 0)
        XCTAssertEqual(input.permissionRequests, 1)
    }

    func testLatePermissionDoesNotRestartAfterLeaving() {
        let input = FakeInput()
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.stop(for: .tuner)
        input.answer(true)
        XCTAssertEqual(recovery.state, .idle)
        XCTAssertEqual(input.startCount, 0)
    }

    func testPermissionChangedInSettingsIsReadOnForeground() {
        let input = FakeInput()
        input.permission = .denied
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .settings)
        recovery.setForeground(false)
        input.permission = .granted
        recovery.setForeground(true)
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 1)
    }

    func testTwoScreensShareOneInputAndOnlyLastDepartureStopsIt() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.start(for: .tuner)
        recovery.start(for: .settings)
        let stops = input.stopCount
        recovery.stop(for: .tuner)
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 1)
        XCTAssertEqual(input.stopCount, stops)
        recovery.stop(for: .settings)
        XCTAssertEqual(recovery.state, .idle)
        XCTAssertGreaterThan(input.stopCount, stops)
    }

    func testUnavailableInputCanRecoverOnRouteChange() {
        let input = FakeInput()
        input.permission = .granted
        input.startError = MicrophoneInputError.unavailable
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        XCTAssertEqual(recovery.state, .inputUnavailable)
        input.startError = nil
        recovery.routeChanged()
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 2)
    }

    func testStartupFailureCanBeRetried() {
        let input = FakeInput()
        input.permission = .granted
        input.startError = NSError(domain: "AudioTest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Activation failed"])
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        XCTAssertEqual(recovery.state, .failed("Activation failed"))
        input.startError = nil
        recovery.retry()
        XCTAssertEqual(recovery.state, .running)
    }

    func testInterruptionStopsInputAndResumesOnlyWhenAllowed() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.interruptionBegan()
        XCTAssertEqual(recovery.state, .interrupted)
        recovery.routeChanged()
        XCTAssertEqual(input.startCount, 1)
        recovery.interruptionEnded(shouldResume: true)
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 2)
    }

    func testManualResumeRequirementSurvivesRouteAndForegroundEvents() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.interruptionBegan()
        recovery.interruptionEnded(shouldResume: false)
        recovery.routeChanged()
        recovery.setForeground(false)
        recovery.setForeground(true)
        XCTAssertEqual(recovery.state, .resumeRequired)
        XCTAssertEqual(input.startCount, 1)
        recovery.retry()
        XCTAssertEqual(recovery.state, .running)
    }

    func testLeavingDuringInterruptionDoesNotResumeRecording() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.interruptionBegan()
        recovery.stop(for: .tuner)
        recovery.interruptionEnded(shouldResume: true)
        recovery.routeChanged()
        XCTAssertEqual(recovery.state, .idle)
        XCTAssertEqual(input.startCount, 1)
    }

    func testBackgroundDefersPermissionGrantAndInterruptionRecovery() {
        let input = FakeInput()
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.setForeground(false)
        input.answer(true)
        recovery.interruptionBegan()
        recovery.interruptionEnded(shouldResume: true)
        XCTAssertEqual(recovery.state, .background)
        XCTAssertEqual(input.startCount, 0)
        recovery.setForeground(true)
        XCTAssertEqual(recovery.state, .running)
    }

    func testMediaServicesLossWaitsForResetAndRebuilds() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.mediaServicesLost()
        recovery.routeChanged()
        recovery.retry()
        XCTAssertEqual(recovery.state, .mediaServicesUnavailable)
        XCTAssertEqual(input.startCount, 1)
        recovery.mediaServicesReset()
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 2)
    }

    func testOldGraphCallbacksCannotPublishAfterStopOrRebuild() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        var accepted: [Float] = []
        recovery.onMeasurement = { pitch, _ in accepted.append(pitch) }
        recovery.start(for: .tuner)
        let old = input.measurement
        old?(440, 1)
        recovery.routeChanged()
        old?(220, 1)
        input.measurement?(880, 1)
        recovery.stop(for: .tuner)
        input.measurement?(660, 1)
        XCTAssertEqual(accepted, [440, 880])
    }

    func testInterruptionEndWhileIdleDoesNotPauseTheNextSession() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.interruptionBegan()
        recovery.stop(for: .tuner)
        recovery.interruptionEnded(shouldResume: false)
        recovery.start(for: .tuner)
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 2)
    }

    func testExplicitRetryRecoversIfInterruptionEndWasNotDelivered() {
        let input = FakeInput()
        input.permission = .granted
        let recovery = MicrophoneRecovery(input: input)
        recovery.start(for: .tuner)
        recovery.interruptionBegan()
        recovery.retry()
        XCTAssertEqual(recovery.state, .running)
        XCTAssertEqual(input.startCount, 2)
    }
}
