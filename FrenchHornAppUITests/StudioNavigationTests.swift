import XCTest

/// End-to-end coverage for the audio ownership boundaries introduced by the tab shell.
final class StudioNavigationTests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launch()
        if app.buttons["instrument.2"].waitForExistence(timeout: 3) {
            app.buttons["instrument.2"].tap()
        }
        XCTAssertTrue(app.buttons["Fingerings"].firstMatch.waitForExistence(timeout: 10))
        waitForOrientation(landscape: false)
    }

    override func tearDownWithError() throws {
        // XCTest can abort a method before Swift defer runs after an assertion failure.
        XCUIDevice.shared.orientation = .portrait
        app.terminate()
    }

    func testMetronomeStopsWhenCoveredLeavingTabAndBackgrounding() {
        app.buttons["Metronome"].firstMatch.tap()
        setExactTempo("120")
        let transport = app.buttons["metronome.transport"]
        expectLabel(transport, "Start metronome")
        transport.tap()
        expectLabel(transport, "Stop metronome")

        let oldTempo = app.descendants(matching: .any)["metronome.tempo"].value as? String
        app.buttons["Increase tempo"].tap()
        XCTAssertNotEqual(app.descendants(matching: .any)["metronome.tempo"].value as? String, oldTempo)
        expectLabel(transport, "Stop metronome")

        app.buttons["studio.settings.metronome"].tap()
        XCTAssertTrue(app.buttons["settings.done"].waitForExistence(timeout: 5))
        app.buttons["settings.done"].tap()
        expectLabel(transport, "Start metronome")

        transport.tap()
        app.buttons["Fingerings"].firstMatch.tap()
        app.buttons["Metronome"].firstMatch.tap()
        expectLabel(transport, "Start metronome")

        transport.tap()
        XCUIDevice.shared.press(.home)
        app.activate()
        expectLabel(transport, "Start metronome")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["Metronome"].firstMatch.isSelected)
        expectLabel(transport, "Start metronome")
        capture("Metronome tab")
    }

    func testInstrumentAndAppearanceSettings() {
        app.buttons["Fingerings"].firstMatch.tap()
        app.buttons["studio.settings.fingerings"].tap()
        app.buttons["settings.instrument"].tap()
        let instrument = app.buttons["instrument.5"]
        for _ in 0..<5 where !instrument.isHittable { app.swipeUp() }
        XCTAssertTrue(instrument.isHittable)
        instrument.tap()

        let appearance = app.buttons["settings.appearance"]
        XCTAssertTrue(appearance.waitForExistence(timeout: 5))
        appearance.tap()
        app.buttons["Low light"].tap()
        capture("Settings low light")
        app.buttons["settings.done"].tap()
        let name = "Single Horn in B♭ (Music Written in B♭)"
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 5))
        XCTAssertEqual(app.alerts.count, 0)
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 5))
        capture("Fingerings low light")
    }

    func testDeniedMicrophoneStillAllowsMetronome() {
        app.buttons["Tuner"].firstMatch.tap()
        let system = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if system.alerts.firstMatch.waitForExistence(timeout: 3) {
            system.alerts.buttons["Don’t Allow"].tap()
        }
        XCTAssertTrue(app.staticTexts["Allow microphone access in Settings to use the tuner."].waitForExistence(timeout: 8))
        expectValue(app.descendants(matching: .any)["tuner.pitch"], "No note")
        capture("Tuner permission denied")
        app.buttons["Metronome"].firstMatch.tap()
        let transport = app.buttons["metronome.transport"]
        transport.tap()
        expectLabel(transport, "Stop metronome")
        transport.tap()
    }

    func testFingeringSelectorSpellingsAlternativesAndRangeBoundaries() {
        app.buttons["Fingerings"].firstMatch.tap()
        chooseHorn(2)
        let written = app.staticTexts["fingerings.writtenPitch"]
        expectValue(written, "C5")
        expectValue(app.staticTexts["fingerings.soundingPitch"], "F4, 349.2 Hz")
        expectValue(app.staticTexts["fingerings.count"], "2")
        capture("Fingerings double C5")

        app.buttons["fingerings.note"].tap()
        app.buttons["C♯5"].tap()
        expectValue(written, "C♯5")
        expectValue(app.staticTexts["fingerings.count"], "3")
        app.buttons["fingerings.spelling"].tap()
        expectValue(written, "D♭5")
        expectValue(app.staticTexts["fingerings.soundingPitch"], "G♭4, 370.0 Hz")

        app.buttons["fingerings.octave"].tap()
        app.buttons["6"].tap()
        expectValue(written, "C6")
        XCTAssertFalse(app.buttons["fingerings.next"].isEnabled)
        app.buttons["fingerings.octave"].tap()
        app.buttons["2"].tap()
        expectValue(written, "C2")
        XCTAssertFalse(app.buttons["fingerings.previous"].isEnabled)
        XCTAssertTrue(app.descendants(matching: .any)["fingerings.staff"].label.contains("8 ledger lines"))
        capture("Fingerings low C2")

        app.buttons["fingerings.octave"].tap()
        app.buttons["5"].tap()
        chooseHorn(5)
        expectValue(written, "C5")
        expectValue(app.staticTexts["fingerings.soundingPitch"], "B♭4, 466.2 Hz")
        capture("Fingerings selector")
    }

    func testReferencePlaybackStopsWhenPitchContextOrVisibilityChanges() {
        app.buttons["Fingerings"].firstMatch.tap()
        chooseHorn(2)
        let transport = app.buttons["reference.transport"]
        transport.tap()
        expectLabel(transport, "Stop reference")
        app.buttons["fingerings.next"].tap()
        expectLabel(transport, "Play reference")
        transport.tap()
        app.buttons["fingerings.spelling"].tap()
        expectLabel(transport, "Stop reference") // Enharmonic spelling keeps the same sounding pitch.

        app.buttons["studio.settings.fingerings"].tap()
        app.buttons["settings.done"].tap()
        expectLabel(transport, "Play reference")
        transport.tap()
        app.buttons["Metronome"].firstMatch.tap()
        app.buttons["Fingerings"].firstMatch.tap()
        expectLabel(transport, "Play reference")
        transport.tap()
        XCUIDevice.shared.press(.home)
        app.activate()
        expectLabel(transport, "Play reference")
        transport.tap()
        chooseHorn(5)
        expectLabel(transport, "Play reference")
        capture("Fingerings reference transport")
    }

    func testTunerCanPauseResumeAndHideInactiveMeasurements() {
        app.buttons["Tuner"].firstMatch.tap()
        let staff = app.descendants(matching: .any)["tuner.staff"]
        XCTAssertTrue(staff.exists)
        XCTAssertFalse(app.buttons["Written note on staff"].exists)
        let listening = app.buttons["tuner.listening"]
        expectLabel(listening, "Pause tuner")
        listening.tap()
        expectLabel(listening, "Resume tuner")
        expectValue(app.descendants(matching: .any)["tuner.pitch"], "No note")
        XCTAssertFalse(app.descendants(matching: .any)["tuner.meter"].exists)
        XCTAssertTrue(staff.exists)
        XCTAssertTrue(staff.label.contains("no note detected"))
        XCTAssertTrue(app.staticTexts["Tuner paused"].exists)
        listening.tap()
        expectLabel(listening, "Pause tuner")
        app.buttons["studio.settings.tuner"].tap()
        app.buttons["settings.done"].tap()
        expectLabel(listening, "Pause tuner")
        capture("Tuner recovery layout")
    }

    func testTapTempoAndCompoundMeterKeepPlaybackRunning() {
        app.buttons["Metronome"].firstMatch.tap()
        let transport = app.buttons["metronome.transport"]
        transport.tap()
        expectLabel(transport, "Stop metronome")
        app.buttons["metronome.meter"].tap()
        app.buttons["6/8"].tap()
        XCTAssertTrue(app.staticTexts["metronome.unit"].label.contains("Eighth"))
        XCTAssertTrue(app.descendants(matching: .any)["metronome.bar"].label.contains("6 clicks"))
        app.buttons["metronome.tapTempo"].tap()
        app.buttons["metronome.tapTempo"].tap()
        expectLabel(transport, "Stop metronome")
        let value = app.descendants(matching: .any)["metronome.tempo"].value as? String ?? ""
        let number = Double(value.components(separatedBy: " ").first ?? "") ?? 0
        XCTAssertTrue((40...208).contains(number))
        transport.tap()
        capture("Metronome compound meter")
    }

    func testAccessibilityTextKeepsSelectorsDiagramsAndTransportReachable() {
        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        app.buttons["Fingerings"].firstMatch.tap()
        chooseHorn(3)
        let transport = app.buttons["reference.transport"]
        XCTAssertTrue(transport.isHittable)
        let noteMenu = app.buttons["fingerings.note"]
        for _ in 0..<8 where !noteMenu.isHittable { app.swipeUp() }
        XCTAssertTrue(noteMenu.isHittable)
        let row = app.descendants(matching: .any)["fingerings.row.0"]
        for _ in 0..<8 where !row.isHittable || row.frame.maxY > transport.frame.minY { app.swipeUp() }
        XCTAssertTrue(row.isHittable)
        XCTAssertLessThanOrEqual(row.frame.maxY, transport.frame.minY + 1)
        let width = app.windows.firstMatch.frame.width
        XCTAssertLessThanOrEqual(row.frame.maxX, width + 1)
        XCTAssertGreaterThanOrEqual(row.frame.minX, 0)
        capture("Fingerings accessibility text")
        app.buttons["Metronome"].firstMatch.tap()
        XCTAssertTrue(app.buttons["metronome.transport"].isHittable)
        capture("Metronome accessibility text")
    }

    func testLandscapeKeepsAllToolTransportsReachable() {
        app.buttons["Metronome"].firstMatch.tap()
        setExactTempo("120")
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        waitForOrientation(landscape: true)
        app.buttons["Fingerings"].firstMatch.tap()
        XCTAssertTrue(app.buttons["reference.transport"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["reference.transport"].isHittable)
        let selector = app.buttons["fingerings.note"]
        for _ in 0..<8 where !fullyVisible(selector, above: app.buttons["reference.transport"]) {
            reveal(selector, above: app.buttons["reference.transport"])
        }
        capture("Fingerings landscape")
        if !selector.isHittable {
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "Landscape selector hierarchy"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
        }
        XCTAssertTrue(selector.isHittable)
        app.buttons["Metronome"].firstMatch.tap()
        XCTAssertTrue(app.buttons["metronome.transport"].isHittable)
        let faster = app.buttons["Increase tempo"]
        for _ in 0..<8 where !fullyVisible(faster, above: app.buttons["metronome.transport"]) {
            reveal(faster, above: app.buttons["metronome.transport"])
        }
        if !faster.isHittable {
            capture("Metronome landscape reachability failure")
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.name = "Landscape metronome hierarchy"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
        }
        XCTAssertTrue(faster.isHittable)
        let oldTempo = app.descendants(matching: .any)["metronome.tempo"].value as? String
        faster.tap()
        capture("Metronome landscape")
        let changed = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            guard let value = self.app.buttons["metronome.tempo"].value as? String else { return false }
            return value != oldTempo
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 8), .completed)
        app.buttons["Tuner"].firstMatch.tap()
        XCTAssertTrue(app.buttons["tuner.listening"].isHittable)
    }

    func testExactTempoEntryAppliesLiveAndCancelPreservesTempo() {
        app.buttons["Metronome"].firstMatch.tap()
        app.buttons["metronome.meter"].tap()
        app.buttons["4/4"].tap()
        for landscape in [false, true] {
            XCUIDevice.shared.orientation = landscape ? .landscapeLeft : .portrait
            waitForOrientation(landscape: landscape)
            setExactTempo("120")
            let transport = app.buttons["metronome.transport"]
            transport.tap()
            expectLabel(transport, "Stop metronome")
            app.buttons["metronome.tempo"].tap()
            let field = app.textFields["metronome.tempoEntry"]
            XCTAssertTrue(field.waitForExistence(timeout: 5))
            replaceTempoText("209")
            XCTAssertFalse(app.buttons["metronome.tempoEntry.save"].isEnabled)
            replaceTempoText("")
            XCTAssertFalse(app.buttons["metronome.tempoEntry.save"].isEnabled)
            replaceTempoText("96")
            XCTAssertTrue(app.buttons["metronome.tempoEntry.save"].isEnabled)
            capture(landscape ? "Exact tempo landscape" : "Exact tempo entry")
            app.buttons["metronome.tempoEntry.save"].tap()
            expectValue(app.buttons["metronome.tempo"], "96 quarter notes per minute")
            expectLabel(transport, "Stop metronome")
            app.buttons["metronome.tempo"].tap()
            replaceTempoText("144")
            app.buttons["metronome.tempoEntry.cancel"].tap()
            expectValue(app.buttons["metronome.tempo"], "96 quarter notes per minute")
            expectLabel(transport, "Stop metronome")
            transport.tap()
        }
    }

    func testMetronomePreferencesRestoreWithoutRestartingPlayback() {
        app.buttons["Metronome"].firstMatch.tap()
        setExactTempo("96")
        app.buttons["metronome.meter"].tap()
        app.buttons["3/4"].tap()
        let accent = app.switches["metronome.accent"]
        if accent.value as? String == "1" { accent.tap() }
        expectValue(accent, "0")
        app.buttons["metronome.transport"].tap()
        expectLabel(app.buttons["metronome.transport"], "Stop metronome")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["Metronome"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Metronome"].firstMatch.isSelected)
        expectValue(app.buttons["metronome.tempo"], "96 quarter notes per minute")
        XCTAssertTrue(app.buttons["metronome.meter"].label.contains("3/4"))
        expectValue(app.switches["metronome.accent"], "0")
        expectLabel(app.buttons["metronome.transport"], "Start metronome")
        capture("Remembered metronome settings")
    }

    private func setExactTempo(_ text: String) {
        app.buttons["metronome.tempo"].tap()
        XCTAssertTrue(app.textFields["metronome.tempoEntry"].waitForExistence(timeout: 5))
        replaceTempoText(text)
        app.buttons["metronome.tempoEntry.save"].tap()
    }

    private func replaceTempoText(_ text: String) {
        let field = app.textFields["metronome.tempoEntry"]
        field.tap()
        let old = field.value as? String ?? ""
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count) + text)
    }

    private func chooseHorn(_ id: Int) {
        app.buttons["studio.settings.fingerings"].tap()
        app.buttons["settings.instrument"].tap()
        let instrument = app.buttons["instrument.\(id)"]
        for _ in 0..<5 where !instrument.isHittable { app.swipeUp() }
        XCTAssertTrue(instrument.isHittable)
        instrument.tap()
        app.buttons["settings.done"].tap()
    }

    private func waitForOrientation(landscape: Bool) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            let frame = self.app.windows.firstMatch.frame
            return frame.width > 0 && frame.height > 0 && (frame.width > frame.height) == landscape
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 5), .completed)
    }

    private func toolViewport(above transport: XCUIElement) -> (top: CGFloat, bottom: CGFloat) {
        let scroll = app.scrollViews.firstMatch.frame
        return (max(app.navigationBars.firstMatch.frame.maxY, scroll.minY) + 16,
                min(transport.frame.minY, scroll.maxY) - 16)
    }

    private func fullyVisible(_ element: XCUIElement, above transport: XCUIElement) -> Bool {
        let viewport = toolViewport(above: transport)
        return element.isHittable && element.frame.minY >= viewport.top && element.frame.maxY <= viewport.bottom
    }

    private func reveal(_ element: XCUIElement, above transport: XCUIElement) {
        // SwiftUI exposes a full-window scroll frame including safe-area insets.
        // Respect the visible viewport and reverse direction after any overshoot.
        let (top, bottom) = toolViewport(above: transport)
        let upward = element.frame.midY > (top + bottom) / 2
        let needed = upward ? element.frame.maxY - bottom : top - element.frame.minY
        let distance = min((bottom - top) * 0.6, max(44, needed))
        let origin = app.coordinate(withNormalizedOffset: .zero)
        // Drag through the content's leading padding. The center can contain the
        // tempo button or slider, which consumes the gesture instead of scrolling.
        let window = app.windows.firstMatch.frame
        let x = window.minX + max(80, (window.width - 680) / 2 + 8)
        let start = upward ? bottom : top
        let end = start + (upward ? -distance : distance)
        origin.withOffset(CGVector(dx: x, dy: start))
            .press(forDuration: 0.05, thenDragTo: origin.withOffset(CGVector(dx: x, dy: end)),
                   withVelocity: .slow, thenHoldForDuration: 0.3)
    }

    private func expectValue(_ element: XCUIElement, _ value: String, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 8), .completed, file: file, line: line)
    }

    private func expectLabel(_ element: XCUIElement, _ label: String, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label == %@", label), object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 8), .completed, file: file, line: line)
    }

    private func capture(_ name: String) {
        // Allow label and navigation transitions to finish before saving review artifacts.
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
