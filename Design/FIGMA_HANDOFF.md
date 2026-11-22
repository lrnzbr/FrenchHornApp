# Adagio instrument apps: Figma handoff

## Design source

[Adagio Instrument Apps — Core Tools](https://www.figma.com/design/KmavF53lyemKiZQ6mbdaK0) is the shared Figma design file. Its first page contains editable light-mode horn layouts for Fingerings, Tuner, and Metronome. The file also contains `Adagio / Color` variables with Light and Low light modes and `Adagio / Layout` variables derived from [adagio-tokens.json](adagio-tokens.json).

These layouts are an initial design baseline, not a sign-off or a pixel-perfect capture of the current SwiftUI app. Figma's preview did not render SF Pro text in this session, so the layouts use Inter as a visible stand-in. The native app continues to use the iOS system font. Musical staff lines in the Figma draft are schematic; the native `StaffPreview` remains the behavior reference until the notation component is designed and reviewed.

## Design-to-code workflow

1. Explore and review each new or changed user flow in Figma, including its normal, empty, error, permission, and low-light states where relevant.
2. Record the approved frame and its expected behavior in the implementation issue or change description. Keep written and sounding pitch labels, instrument identity, input status, and audio controls explicit.
3. Implement in SwiftUI using `AdagioTheme`, the existing audio controllers, and instrument-specific musical models. Compare the implemented screen with the approved Figma frame on an iPhone and iPad.
4. Update Figma and `adagio-tokens.json` together when a shared visual decision changes. Document intentional platform differences in the change description.

## Release scope agreed 12 November 2026

- The next public horn release covers the existing three core tools: Fingerings, Tuner, and Metronome. Warmups, ear training, range profiles, and passive listening are later releases.
- Trumpet, Flute, and Clarinet launch parity means those same three tools with correct instrument-specific fingerings, written/sounding pitch behavior, notation, and playable ranges. Their existing projects are starting points, not validated parity builds.

## Horn release gate

- The current TestFlight candidate is 1.3.0 (1). App Store Connect shows it installed on an iPhone Duo with iOS 27.3 on 12 November 2026, and the 1.3.0 App Store draft has that build attached. The physical acceptance run is not yet recorded.
- The owner's existing tester account was reinvited on 12 November 2026 and has since installed the build.
- Run the [TestFlight acceptance suite](../Testing/TESTFLIGHT_TEST_SUITE.md) on a physical iPhone and iPad, especially tuner recovery, audio routes, metronome behavior, and accessibility.
- The Swift package regression suite passed on 12 November 2026 with **76 tests, 0 failures** when run with normal macOS CoreAudio access. The restricted workspace sandbox could not initialize CoreAudio for five rendering tests; those same tests passed outside that restriction. The native `FrenchHornApp-UI` suite passed on the dedicated iOS 27.0 Adagio review simulator with **11 tests, 0 failures**. These results do not replace physical TestFlight acceptance.
- Resolve release blockers, verify App Store Connect metadata and privacy answers against the submitted build, then submit for App Review. A TestFlight upload alone is not a public release.
