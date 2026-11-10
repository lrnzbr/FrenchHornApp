# Adagio Studios — Studio design direction

**Status:** design study with the three core native tool screens implemented, 19 October 2026. The SwiftUI app now uses the shared theme, three-tool shell, themed settings, note selectors, vector staff, alternate fingering rows, tuning meter and tap tempo. “Adagio” is a provisional suite identity, not an approved replacement App Store name. Open [the prototype](index.html) in a browser; it works locally without a server, dependencies, account, microphone permission or network access.

## Recommended direction

Use a quiet, warm practice workspace: paper surfaces, dark green-black ink, a restrained brass accent, large measurements and familiar native controls. Give the musician direct access to **Fingerings**, **Tuner** and **Metronome**, rather than a menu that hides the tools. Settings stays in the same upper-right position. Reopen the last-used tool; use Fingerings on a first launch, after instrument selection.

This is a working tool used on a music stand. Its hierarchy should still make sense at arm’s length: note or tempo first, actionable feedback second, configuration third. Waveforms, FFTs and amplitude diagnostics should move into an optional input details view. They should not compete with the note and tuning direction.

Three directions were considered:

| Direction | Character | Decision |
| --- | --- | --- |
| **Studio** | Warm paper, clear ink, brass details; serif only in the identity | Recommended; developed in the interactive study |
| Score | Mostly monochrome, engraved notation and compact reference lists | Useful for the later score reader, less differentiation for the everyday tools |
| Precision | Dark technical panels, denser meters, vivid signal colors | Useful as an optional diagnostics treatment; too much competing information for the main tuner |

Low light is an appearance of Studio, with the same hierarchy and controls. It is not a separate product identity. Branding, the provisional lettermark and naming need their own later pass.

## Mobbin research

Four searches covered audio capture, focused timers, music libraries and instrument tuning. Ten returned screens were visually inspected. The instrument-tuner search returned a key-editing sheet, not a tuner, so the pitch meter here is an original adaptation of the app’s musical model. These references establish interaction patterns, not evidence that a musician-specific workflow has been validated.

| Reference | Observed pattern | Application |
| --- | --- | --- |
| [Suno recording](https://mobbin.com/screens/7aa9285e-1472-4a3e-99f3-d320d109fb3b) | One dominant signal area with a small transport underneath | One note/cents area in the tuner; keep diagnostics secondary |
| [Me+ timer](https://mobbin.com/screens/444ab9ea-95f5-4884-a0f9-dbe74bf67b19) | Large central numerals and one clear primary action | Large tempo with a stable Start/Stop position |
| [Quo recorder](https://mobbin.com/screens/fe041609-3f9b-46c4-8a65-6a660b20f6ad) | Spacious signal display, explicit recording state and grouped controls | Separate listening status from tuning accuracy and transport |
| [[untitled] library](https://mobbin.com/screens/c01446b2-41fc-4a97-a621-3dca2912cabe) | Compact filter controls and consistent rows | Compact note selection and alternate-fingering rows; later score-library filters |
| [Duolingo music practice](https://mobbin.com/screens/1e355853-bc73-4fe0-8b5b-96c7824216b4) | Labeled bottom destinations, filters above selectable musical content | Three persistent tool destinations; no gamification or locked content in this pass |
| [[untitled] key selection](https://mobbin.com/screens/50f6e040-df20-4b1d-a87b-976c413e753e) | Explicit accidental spellings in a contained selection surface | Keep sharps/flats discoverable; never silently change the written key |

The prototype uses original layouts and code-drawn symbols. It does not embed Mobbin screenshots or reuse the source apps’ artwork, branding or fonts.

## Navigation and screen responsibilities

| Surface | Primary job | Essential content |
| --- | --- | --- |
| Instrument setup | Establish the correct musical context | Instrument family/configuration, written key, an explicit Continue action; retain all eight current configurations |
| Fingerings | Find a note, see how to play it, hear its sounding pitch | Treble staff, labeled written note/octave, sounding note/frequency, note navigation, all listed fingerings, Play/Stop reference |
| Tuner | Read pitch and direction at a glance | Large written pitch, sounding pitch/frequency, signed cents, Flat/In tune/Sharp text, centered meter, microphone state, recovery action |
| Metronome | Set and maintain a pulse | Large tempo, beat unit, slider and ± controls, meter, accent, beat markers, persistent Start/Stop |
| Settings | Choose instrument and input preferences | Instrument configuration, input routing and sensitivity, appearance, About/support |

The prototype covers the three core tools and the instrument/appearance portion of Settings. Each of the three preview screens can switch between all three tools. Instrument changes synchronize across previews. Audio and microphone activity are simulated; no browser permissions are requested. The external “Preview state” selector is a review control and must not appear in the app.

The prototype supports note/octave selection, sharps/flats, alternate fingerings, all eight configurations, reference transport states, meter/accent changes, tempo adjustment while playing and Tap tempo. The native implementation now includes those controls, with a separately tested tap-interval model feeding the existing audio controller. Reference playback, tuning and metronome audio still belong to the existing native implementation. Italian tempo terms in the study are optional descriptive copy and must not obscure the exact beat unit.

### Musical presentation rules

- Use scientific pitch notation consistently: middle C is C4, A4 is 440 Hz.
- Always distinguish **Written** from **Sounding** pitch. For a horn written in F, C5 sounds F4, about 349.2 Hz. For B♭-written instruments, C5 sounds B♭4, about 466.2 Hz. The physical B♭ side of a double horn does not change its F-written notation.
- Derive all fingerings, supported notes and transposition from `Instrument`. Never infer them from a display name or color.
- Keep existing fingering order without claiming the first entry is universally preferred. Label alternatives clearly. The study says “First listed.” A pedagogical recommendation needs a separate musical review.
- A filled valve/trigger means pressed; an outlined one means released. Include a text/VoiceOver description. Trigger labels must account for the selected instrument. Woodwind keys and slide positions require different diagrams.
- Use computed diatonic staff position and ledger lines. Do not use fixed per-note screenshots or expand the old displacement lookup. Very low/high notes must fit within the scrollable notation region without clipping; test the full supported range.
- Display tuning direction in words and signed cents. The current ±2-cent in-tune threshold is preserved in the concept. Green is reserved for in-tune status; brass indicates selection, not tuning quality.
- Preserve the native metronome’s 40–208 range and meters. In 6/8, each current click is an **eighth note**, not a dotted quarter. A compound-meter regrouping control is a later behavior change.

## Shared design tokens

[adagio-tokens.json](adagio-tokens.json) is the portable source for this design study. The browser CSS and native `AdagioTheme` implement the same semantic palette. Keep platform-specific representations separate from their semantic names and update them together when changing the design language.

| Role | Light | Low light | Use |
| --- | --- | --- | --- |
| Canvas | `#F5F3EC` | `#151C18` | Screen background |
| Surface | `#FFFEFA` | `#202B24` | Grouped content and notation |
| Ink | `#232D28` | `#F1F3EA` | Primary text, note glyphs, primary actions |
| Secondary ink | `#616B63` | `#B4C0B3` | Supporting labels |
| Brass accent | `#82601F` | `#DFC18A` | Selection, subtle identity details |
| Success | `#306247` | `#AED5B5` | In-tune feedback |
| Attention | `#A13E35` | `#F5ADA3` | Flat/sharp and actionable input problems, with different words/icons |

Spacing uses 4, 8, 12, 16, 24, 32 and 48 points. Normal screen margins are 24 points; compact widths may use 16. Use 12-point control corners and 20-point panels. Avoid wrapping every label in a card. Hairline separators organize related settings; stronger borders distinguish standalone controls.

Use system typography for UI and SF Symbols for native tool icons. The wordmark may use system serif; music engraving uses a dedicated notation renderer rather than a prose font. Body is a Dynamic Type semantic style; large note and tempo numbers use tabular digits and scale relative to `largeTitle`. The prototype’s smaller review labels are not final native accessibility sizes.

Primary actions are 54 points high; all interactive targets are at least 44×44 points, including navigation arrows and invisible padding around toggles. Measurements should keep a stable baseline when digits change. Prefer instantaneous measurement updates to decorative animation. Honor Reduce Motion and Differentiate Without Color.

### Reusable component contract

| Component | Inputs/state | Across the suite |
| --- | --- | --- |
| `StudioShell` | Current tool, instrument identity, appearance | Same destination positions and settings entry |
| `InstrumentContext` | Configuration ID and written key | Never persist a display string as musical identity |
| `PitchReadout` | Written pitch, sounding pitch, valid/absent state | Same labels and number hierarchy |
| `StaffPreview` | Spelled note(s), clef, bounds | Different clefs/ranges; same engraving layout rules |
| `FingeringDiagram` | Instrument-specific semantic diagram data | Adapter for valves, woodwind keys or slide position |
| `TuningMeter` | Signed cents, threshold, valid state | Shared direction/status behavior |
| `InputStatus` | Permission/recovery state and available action | Same actionable language and retry behavior |
| `TransportButton` | Idle/playing/error and action | Stable Play/Stop position and VoiceOver label |
| `TempoControl` | BPM, range, beat unit, update action | Same controls; use the existing sample-clock controller |
| `SettingRow` | Label, value/control, explanation | Shared row, focus and scaling behavior |

App identity can eventually have a restrained instrument accent or illustration. Status colors, measurements, spacing, navigation and control behavior stay shared. Accent differences must never be the only way to identify an app or interpret feedback.

## Recovery and accessibility

The tuner study includes in-tune, flat, sharp, waiting, permission required, denied, unavailable input, interruption, failure and paused states. In the native app, connect these to `MicrophoneState` / `TunerConductor`; never invent a parallel audio state machine in a view.

| Native condition | Presentation/action |
| --- | --- |
| Permission not yet requested | Explain the need, then request only on entering/activating the tuner |
| Denied | “Microphone access is off”; open iPhone Settings |
| No usable input | Clear the old note and meter, show “Connect a microphone” and Retry |
| Interrupted | Clear live readings; resume automatically only when the coordinator permits; otherwise Resume |
| Route rebuild | Brief input/reconnecting status, then current measurements; no stale note |
| Capture failed | Clear values; show a useful retry action without an engine error dump |
| Backgrounded/paused | Inactive state; no moving meter or false listening indicator |
| Metronome output stopped | Show Stop-to-Start transition and existing error/restart message; do not keep animating |

Native acceptance requires VoiceOver reading order, status announcements that do not spam every pitch update, Dynamic Type through accessibility sizes, increased contrast, reduced motion, landscape and iPad layouts. At large type sizes, stack the pitch metadata and settings rows vertically; preserve scrolling and keep the transport reachable. Do not shrink important text to fit the three-phone review board. A simple accessible cents value must remain available even if the visual gauge cannot fit.

The low-contrast decorative separators are not the only affordance for a control; use `borderStrong` for essential control outlines. Token foreground/background contrast is checked during this study, but a passing palette alone is not an accessibility certification.

## Incremental native implementation

1. **Foundations:** add semantic light/dark colors, semantic type, spacing and shared controls in `Theme`; add previews for normal/large text and all input states. Keep the existing controllers and musical model.
2. **Navigation and fingerings:** replace the main menu with the three-tool shell, preserve the stored instrument and instrument-setup flow, then introduce compact notation/fingering rows and a reachable reference transport. Validate all eight configurations and the extreme ledger notes.
3. **Tuner:** bind the new readout/meter/recovery presentation to `TunerConductor`. Move the existing input picker and sensitivity controls into an input details/settings surface. Stop the microphone appropriately when leaving the tuner. Remove diagnostic graphs from the main hierarchy.
4. **Metronome:** move the metronome into its own destination using the existing `MetronomeController`. Maintain live tempo behavior, meter semantics and playback lifecycle. Feed Tap tempo into that controller without introducing another audio clock. Separating tabs changes simultaneous tuner/metronome use: for this shell, leaving a tool stops its audio, consistent with current lifecycle handling. A later shared mini-transport needs explicit audio-coexistence validation.
5. **Device validation and rollout:** run the existing musical/audio/metronome regression suite, unsigned simulator build, device recovery checks and accessibility pass. Ask the current horn players to complete real tasks, then refine before reusing the system in another instrument app.

Suggested musician tasks: find and hear a written B♭4 without confusing concert pitch; compare both C5 fingerings on a double horn; recognize a flat note from a stand’s distance; recover after removing a USB microphone; change tempo during playback; explain what a 6/8 click means. Record completion, confusion and reachability rather than only asking whether the screen looks attractive.

## Future features without premature navigation

Do not add inactive destinations for the roadmap. Ear training and range analysis can become focused practice tools when mature. Structured scores/etudes need a library and reader with import, playback and explicit transposition context; community publishing is a separate later layer. Shared notation and pitch components should make that expansion possible without dictating the file format now.

The minimal Apple Watch idea should reuse the pitch hierarchy and status language, with one tuner reading and only essential context. Do not compress the phone’s navigation onto the watch. Squeak detection, weather-related tuning guidance and instrument-quality analysis remain research items, with no implied accuracy or unsupported diagnosis in this design.

## Local review

Open `Design/index.html` directly, or serve this directory with a local static server. Toggle Low light; use the tabs inside each preview; open Settings to change horn configuration; choose tuner conditions using the review control below a tuner preview. Playback is simulated. Nothing is recorded or transmitted.

The checked-in `instrument-fixtures.js` is generated from the app’s actual Swift model, not a manually recreated fingering chart. After musical model changes, refresh it from the repository root:

```sh
python3 Design/scripts/export-fixtures.py
```

The exporter compiles only the model and runs locally. Swift may need access to its normal compiler cache. The prototype does not ship in the Xcode app target.

### Review completed

Checked in headless Chrome at 1440px and 375px viewport widths: all three tool destinations, all eight instrument configurations, ten tuner scenarios, clearing stale notes on inactive input, recovery actions, note-range extremes/ledger bounds, live tempo and meter controls, accents, keyboard tab navigation and dialog dismissal. Main transport controls are visible on the initial screens; there is no horizontal page overflow at 375px. No JavaScript errors were reported. Light, low-light, narrow-layout and denied-permission screenshots are in [previews](previews/).

Palette calculations on the canvas background: light text roles range from 4.99:1 (secondary) to 12.80:1 (primary); low-light text roles range from 9.19:1 to 15.48:1. Essential control outlines are 3.29:1 in light and 5.26:1 in low light. These checks do not cover native VoiceOver, Dynamic Type or physical device usability; those remain implementation acceptance work.

### Native implementation

`AdagioTheme.swift` maps the palette to adaptive iOS colors, shared spacing/radii, semantic type and UIKit bar appearances for the iOS 15.5 deployment target. `AdagioComponents.swift` supplies primary/secondary button styles, surfaces and scaling measurement text, with light, low-light and accessibility-size previews. System/Light/Low light follows a persisted user preference.

`MainMenu` now hosts native Fingerings, Tuner and Metronome tabs with one navigation container per destination and Settings access from each. The saved instrument is reused, and a first launch selects it before showing the shell. The former two-second splash delay has been removed from the launch path. The chosen tool is persisted without persisting any playing/recording state.

The tuner owns its existing `.tuner` recording lease only when selected and not covered by Settings. Metronome playback stops on tab exit or when Settings opens and requires a new Play afterward. Input setup is a separate Settings destination and uses the existing `.settings` lease. Existing interruption, route-change and background handlers remain the source of audio recovery behavior.

Compact-height phone layouts use the tool name in the navigation bar and reduce the transport's padding; the redundant reference caption is omitted there. At accessibility text sizes, visible transport titles use short verbs while their VoiceOver labels retain the full action. Tool content scrolls independently above the pinned controls. Tablet content has a 680-point maximum width and keeps the platform's native floating tabs.

The musical calculations, microphone recovery and sample-clock renderer were preserved. Fingerings derives its written note, sounding note and reference frequency from the current instrument on every render. Only the user's MIDI/spelling choice is stored in view state, avoiding stale transposition after changing instruments in Settings. A pure `FingeringSelection` model handles chromatic stepping, partial octaves and supported-range boundaries; spelling changes retain the same sounding pitch. Every existing alternate remains in its original table order, labeled “First listed” or “Alternative” without a new pedagogical ranking. Valve diagrams encode pressed/released states in both appearance and VoiceOver values, and wrap at accessibility text sizes.

`StaffPreview` uses vector staff/ledger lines and a whole-note glyph with the existing corrected diatonic positions. `StaffPreviewLayout` expands for extreme ledger notes; it does not displace or clamp the selected pitch. The treble-clef asset is template tinted for both appearances. Instrument/hand illustrations remain available in a disclosure. Reference playback keeps its output-only session and stops on note, instrument, visibility, interruption or route changes. An enharmonic spelling change alone does not interrupt the tone.

The native tuner emphasizes written pitch, sounding pitch, signed cents and direction. Its gauge consumes `TunerPresentation`, which uses the existing `TunerReading` target and clears every stale value unless input is running. The center band's width scales with the same ±2-cent threshold at every screen width. Pause/Resume controls the existing tuner lease. Musician feedback during hardware testing restored staff notation directly inside the main pitch readout, without a disclosure. The complete last valid result now persists for 1.5 seconds after its measurement, labeled “Last written pitch” during silence; new notes replace it immediately. Repeated silence does not extend the deadline. Pause, inactive input and lifecycle cleanup clear it immediately, retaining the empty clef/staff. `TunerDisplayHold` uses monotonic time and holds presentation only; raw capture and tuning calculations are unchanged. Waveform/FFT diagnostics are in Microphone & input settings rather than the practice screen. Preview data exercises flat, sharp, in-tune and waiting layouts without recording audio.

The metronome uses the existing controller with themed controls and a transport inset above the tab bar. `TapTempo` uses up to five valid recent intervals and a median to reduce the effect of an uneven tap; bounce, invalid timestamps and long pauses have explicit regression coverage. Manual adjustment and playback cleanup reset tap history. The static bar display shows click count and accent; 6/8 explicitly counts eighth-note clicks. Beat animation remains future work because it needs synchronization with the audio renderer and output latency, rather than an independent UI timer.

The tempo number opens a numeric-entry sheet with the current click unit, a whole-number 40–208 range, and explicit Cancel/Set tempo actions. Invalid text cannot be applied. Applying a tempo feeds the existing controller while playback continues. Tempo, meter and accent are stored together with a versioned, validated preference record; corrupt or unsupported records use the standard settings. Playing state is never stored and relaunch always leaves output stopped.

Validation completed on 19 October 2026:

| Check | Result |
| --- | --- |
| Core model/audio regression suite | 66 tests passed after the hardware-audition fix, including actual reference-sampler rendering, all eight fingering configurations, transposition, ledger bounds, inactive tuner values, the ±2-cent meter boundary and tap intervals |
| Unsigned simulator app build | Passed using the full Xcode toolchain; deployment target remains iOS 15.5 |
| iPhone 17, iOS 27.0 | Nine UI scenarios passed: eight portrait/lifecycle checks plus the compact landscape check |
| iPad Pro 11-inch (M5), iOS 27.0 | All nine UI scenarios passed; the two affected layout checks passed again after the final large-text/landscape refinements |
| Source/project checks | `git diff --check` and Xcode project plist validation passed |

UI scenarios cover denied-microphone metronome use; instrument and appearance persistence; sharp/flat spelling, partial octaves, range limits and low ledgers; F/B♭ instrument switching; reference cleanup on note/context/visibility changes; metronome cleanup across Settings, tabs, background and relaunch; tap tempo/6/8 semantics; tuner pause/resume; accessibility text and landscape transport reachability. No UI test grants microphone permission or records sound. Real pitch layouts have preview data and pure calculation coverage; live microphone accuracy is not established by simulator screenshots.

Current captures: [fingerings](previews/native-fingerings.png), [low C2](previews/native-fingerings-low-c2.png), [tuner permission](previews/native-tuner-permission.png), [metronome](previews/native-metronome.png), [phone landscape](previews/native-fingerings-landscape.png), [iPad light](previews/native-ipad-fingerings-light.png), [iPad landscape](previews/native-ipad-landscape.png), and [accessibility text](previews/native-fingerings-accessibility.png).

Physical input, interruption and route observations follow below. Remaining device checks, independent calibration and musician usability are tracked in the [TestFlight suite](../Testing/TESTFLIGHT_TEST_SUITE.md). Native UI automation checks accessibility values, reachability and large text; a spoken VoiceOver review remains necessary. These runtime checks used iOS 27.0 and do not certify behavior on every older supported OS.

### Physical iPad session · 19 October 2026

Setup: iPad Pro 13-inch (M5), iPadOS 27.0; double horn in F/B♭; built-in microphone and speakers; A4 = 440 Hz. The development build was signed, installed and launched successfully. A device screenshot confirmed the double-horn fingering screen at written C5, sounding F4 / 349.2 Hz, with both existing fingerings visible. This confirms installation and UI state, not audible calibration.

| Hardware check | Status |
| --- | --- |
| Reference tone, pitch changes and Stop behavior | Corrected octave confirmed by musician on repeat audition; pitch-change and Stop checks remain unconfirmed |
| Microphone permission and live horn tracking | Musician confirms written C5 tracks steadily on the physical iPad with built-in input; fresh permission flow and independent absolute-frequency calibration remain unconfirmed |
| Flat/sharp direction, silence clearing and Pause/Resume | Musician confirms correct flat/sharp response with C5 retained, clearing after silence, and Pause/Resume clearing and restoring live tracking |
| Settings/tab transitions, background and foreground | Musician confirms automatic recovery after backgrounding while listening and preservation of paused intent after backgrounding; Settings/tab transitions remain unconfirmed |
| Siri or other real audio interruption | Musician confirms automatic recovery after Siri while listening and preservation of paused intent when Siri interrupts a paused tuner; other interruption types remain untested |
| Metronome tempo/meter changes and output cleanup | Not yet tested |
| External input/output routes, if available | On 22 October the musician reported the wired-headphone checks working: active connection/removal recovery, paused intent preservation, and reference stopping on removal. Bluetooth and USB microphone/interface checks are deferred to the TestFlight suite |
| Stand-distance readability, rotation and spoken VoiceOver | Not yet tested |

The first hardware audition exposed a gap in the original tests: MIDI/frequency calculations were correct, but the recording was mapped to the wrong sampler root key. Offline rendering reproduced written C5 in F at about 699 Hz instead of 349 Hz. The recording's fundamental is F4, so the preset root was corrected from MIDI 53 (F3) to MIDI 65 (F4). `ReferenceSamplerTests` now renders the actual preset/sample at four sounding pitches and measures their fundamental in two windows, catching an octave error independently of the note-label calculations. The musician confirmed the corrected octave on the physical iPad. Feedback also confirmed that the tuner staff is a valued feature, so it was restored as a visible part of the main tuner readout before continuing horn input tests.

The restored staff consumes the same valid written note as the large pitch label. It remains present without a disclosure, with an empty clef/staff when paused or no pitch is detected. A [physical iPad capture](previews/hardware-ipad-tuner-staff.png) confirms the live layout; the captured note was not a controlled calibration stimulus, so it does not establish pitch accuracy.

The targeted native UI regression passed after this restoration: the staff is present without a disclosure, remains present while paused, exposes “no note detected” instead of stale notation, and survives the existing Resume/Settings transition checks. The signed physical-device build also passed and was installed and launched on the musician's iPad.

### Beta preparation · 22 October 2026

The [TestFlight acceptance suite](../Testing/TESTFLIGHT_TEST_SUITE.md) and [run template](../Testing/TESTFLIGHT_RUN_TEMPLATE.md) define repeatable device checks, evidence requirements and release blockers. They include the new 1.5-second tuner hold, numeric tempo entry and remembered metronome settings. Earlier hardware results above predate these enhancements and do not certify them. No TestFlight run or upload has been performed.

The Swift package now passes 76 regression tests, including five display-hold cases and five preference/entry cases. Coverage includes the hold deadline, repeated silence, immediate note replacement, inactive-state clearing, preference round trips, corrupt/future records and invalid numeric entry. The unsigned simulator app and UI-test builds also pass.

All eleven iPhone 17 scenarios passed across targeted and regression runs on iOS 27.0. Five affected iPad Pro 11-inch (M5) scenarios passed: exact entry in portrait/landscape, remembered settings without restarting output, accessibility text, tuner Pause/Resume, and landscape transport/control reachability. Regression work exposed an unreliable scroll hit area in the blank margins of Fingerings/Metronome; the content now accepts scrolling there. The final landscape reruns pass on both devices and confirm a tempo increment after revealing the controls above the transport. The test helper uses the visible viewport, reverses direction if needed and ends a slow drag without momentum. Existing musical calculations and audio rendering/recovery remain unchanged.

These native checks do not grant microphone access or establish the live hold duration acoustically. The new hold has deterministic model coverage; a musician must still verify it in the beta build. `git diff --check`, project plist validation, all 34 acceptance-case IDs and local documentation links also pass.

Reviewed native captures: [numeric entry](previews/native-tempo-entry.png), [phone landscape entry](previews/native-tempo-entry-landscape.png), [iPad landscape entry](previews/native-ipad-tempo-entry-landscape.png), [restored 96 / 3/4 / accent-off settings with output stopped](previews/native-metronome-remembered.png), and revealed metronome controls on [phone](previews/native-metronome-landscape-enhanced.png) and [iPad](previews/native-ipad-metronome-landscape-enhanced.png). Simulator entry screenshots use the connected hardware keyboard and do not establish software-keyboard behavior on a physical device.
