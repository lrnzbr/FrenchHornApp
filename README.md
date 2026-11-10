## The Hornist Almanac

A toolkit for French Horn Players

## Musical calculation regression tests

The Swift package compiles the app's musical model files directly. Its tests run
on macOS without launching the app, requesting microphone permission, or loading
AudioKit. Use the full Xcode toolchain:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

Coverage includes scientific pitch octaves, F and B♭ transposition, marching horn
fingering assignments, all selectable notes, staff positions and ledger lines,
tuner note/cents boundaries, and invalid or silent measurements. Reference tuning
is A4 = 440 Hz; the tuner displays written pitches from C0 through B8.

The reference sampler regression also renders the shipped preset and recording
silently and measures the audio fundamental. `FrenchHorn.wav` is recorded at F4;
its preset root key must be MIDI 65. The former MIDI 53 mapping raised every
reference by an octave even when the written/sounding labels were correct. The
rendered-audio check covers F and B♭ notation, a lower octave and an accidental;
its 12-cent tolerance allows the recording's small pitch variation.

The package tests validate calculations and generated audio timing. Microphone
accuracy, audible sample calibration, output latency and real audio interruption
recovery require device tests.

## Audio recovery

Microphone permission is requested when opening the tuner or microphone settings.
Denied permission offers a link to system Settings; unavailable input and startup
failures offer a retry. Recording stops in the background and when the last
listening screen closes. Interruptions resume listening when the system permits;
otherwise the player can choose Resume Listening. Route changes rebuild the input
graph, and a disconnected preferred microphone falls back to the system default.

The same test command also covers permission callbacks after navigation, input
failures, interruptions, route changes, foreground recovery, media service resets,
and rejection of measurements from stopped graphs. Reference tones and the
metronome use output-only sessions without microphone permission. They pause after
interruptions, headphone removal, backgrounding, and leaving their screen; tap Play
to start them again.

Before release, verify these cases on an iPhone and iPad:

- Fresh permission grant, denial, and enabling access in Settings afterward.
- Entering and leaving the tuner while the permission prompt is pending.
- A call or Siri interruption, followed by automatic or manual recovery.
- Wired/USB microphone and headphone connection and removal; Bluetooth switching.
- Changing the preferred microphone, disconnecting it, and selecting System Default.
- Backgrounding and returning with the tuner or metronome in use.
- Reference playback and metronome use with microphone permission denied.
- Switching between tools and Settings, checking that covered output stops and
  only the requested microphone screen resumes.
- Written C5 on a horn in F sounds F4; on a horn with B♭ notation it sounds B♭4.
  Compare reference playback and tuner readings against a trusted instrument.
- VoiceOver reading order and spoken valve states, large text, landscape and
  reading the tuner at a music stand's distance.

## Metronome timing

Clicks are synthesized on the audio sample clock using an AVAudioSourceNode,
without a main-thread timer or compressed-audio playback. Tempo, meter, and accent
changes reach the renderer at an audio buffer boundary. Tempo changes preserve
progress through the current beat; a meter change starts a new bar on the next
click. The renderer carries fractional sample intervals forward to avoid drift
from rounding each beat separately.

The supported tempo range is 40–208 BPM. Each click is a quarter note in 2/4,
3/4, and 4/4, or an eighth note in 6/8. The optional accent marks the first click
of each bar. Starting playback begins a fresh bar; repeated Play or Stop calls
are safe. A stopped audio engine after an output configuration change shows a
restart message instead of continuing to display a running metronome.

Regression tests check fractional timing, live tempo and meter changes, accents,
transport cleanup, and the actual audio node through silent offline rendering at
44.1, 48, and 96 kHz. They also exercise concurrent parameter updates. These checks
verify generated sample timing; hardware latency, Bluetooth buffering, and audio
dropouts under device load still require listening and measurement on an iPhone
and iPad. Before release, test fast slider changes and screen interaction at both
tempo limits, plus headset switching and transitions between the tuner and
metronome. The current tab shell stops a tool when another tool is selected.

## Adagio theme and navigation

The native app now opens directly into instrument setup or three practice tabs:
Fingerings, Tuner, and Metronome. It remembers the selected instrument and last
tool. Settings is reachable from every tab, with persistent System, Light, and
Low light appearances. The shared SwiftUI colors, semantic typography, spacing,
surfaces, measurement text and button styles live in `FrenchHornApp/Theme`.

The tuner records only while its tab is selected and Settings is closed. Opening
Settings stops the covered tool; closing it resumes the tuner when appropriate,
but does not restart metronome playback. Leaving the metronome tab stops it.
General Settings does not request microphone permission; its explicit Microphone
& input destination owns the existing settings recording lease. Musical model
calculations, input recovery and the sample-clock metronome are unchanged.

Fingerings now has note and octave selectors, chromatic stepping, sharp/flat
spelling, a theme-aware vector staff and all listed alternate fingerings. Written
pitch, sounding pitch and reference frequency come from the corrected instrument
model. Changing a note or instrument stops the reference tone; changing only its
enharmonic spelling preserves the tone. Valve diagrams expose pressed/released
states to VoiceOver and wrap at accessibility text sizes.

The tuner presents the written and sounding notes, signed cents, direction and a
pitch meter derived from the existing tuning calculation. Paused or unavailable
input clears the readout and hides the needle. Pause/Resume uses the same recording
leases and recovery handling. The written-note staff stays visible alongside the
main readout. After the last valid measurement, the complete result remains for
1.5 seconds, then clears while retaining the empty clef and staff. A new valid
note replaces the held result immediately. Pause, unavailable input and lifecycle
cleanup clear it immediately. Raw capture and tuning calculations remain live;
the hold applies only to the practice display. Waveform and FFT diagnostics live
in Microphone & input settings.

Tap tempo uses the median of up to five recent intervals, ignores switch bounce,
resets after a long pause and respects the existing 40–208 tempo limits. It updates
the existing sample-clock renderer without adding another audio clock. The static
click-pattern display shows the bar count and first-click accent. In 6/8 the tempo
explicitly counts eighth notes. An animated beat indicator still needs a display
clock synchronized with audio output and is not part of this implementation.
Tap the tempo number to enter an exact whole-number tempo from 40 to 208; applying
it updates playback live, and Cancel preserves the previous value. Tempo, meter
and first-beat accent survive relaunch, with invalid saved data falling back to
120 / 4/4 / accented. Playback always starts stopped.

The `FrenchHornApp-UI` shared Xcode scheme runs native navigation checks from
`FrenchHornAppUITests`, in addition to the separate Swift package regression
suite. Run against an available simulator (substitute its name as needed):

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project FrenchHornApp.xcodeproj -scheme FrenchHornApp-UI \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' test
```

Use a disposable simulator: UI tests change the app's instrument/appearance
preferences, deny its microphone permission if prompted, and play/stop the
metronome and reference tone. They do not grant microphone access or record sound.
Coverage includes note spelling/range boundaries, instrument transposition,
reference playback cleanup, tuner pause/resume, tap tempo, exact entry, remembered
metronome settings without automatic playback, and accessibility text.
Landscape checks use the compact phone header and verify scrolling above the
pinned transport. Blank content margins on Fingerings and Metronome also accept
scrolling. At accessibility text sizes, shorter visible transport titles
retain their full VoiceOver action names.

## TestFlight acceptance

Use the [TestFlight acceptance suite](Testing/TESTFLIGHT_TEST_SUITE.md) when a beta
build is available, and copy the [run template](Testing/TESTFLIGHT_RUN_TEMPLATE.md)
for each tester/build/device. It covers musical identity, tuner hold and recovery,
permissions, wired/Bluetooth/USB routes, metronome timing and controls, accessibility
and longer practice sessions. Development-build checks remain separate from beta
results; the new hold and metronome enhancements still need physical beta testing.

Version 1.3.0 (build 1) has a signed Release archive and App Store distribution
export, and was uploaded successfully on 22 October 2026. Apple has finished
processing it. On 23 October, the internal group **Adagio iPad Testing** was
enabled with only the owner's existing account and build 1.3.0 (1), status
**Testing**. Automatic distribution is off; the account is **Invited** and
on-device installation is not yet verified. See the
[build record and packaging commands](Release/README.md) and
[beta test notes](Testing/TESTFLIGHT_WHAT_TO_TEST.txt).

## UI design study

The [Adagio Studios design study](Design/DESIGN.md) documents Mobbin research,
shared visual tokens, component contracts, accessibility requirements and the
incremental SwiftUI migration. Open [the interactive prototype](Design/index.html)
in a browser to explore fingerings, tuner states, metronome controls, all eight
horn configurations and low-light appearance. Its audio is simulated, and it does
not request microphone access. The shared theme, navigation and three core tool
screens are implemented in SwiftUI; the study remains a visual reference and a
place to explore future states.
