# French horn TestFlight acceptance suite

Prepared 22 October 2026. Run against each nominated TestFlight build. This is a
manual device suite; the Swift package and native UI tests are separate checks.
No TestFlight build has been tested or published by creating this document.

## Record the run

Copy [the run template](TESTFLIGHT_RUN_TEMPLATE.md) for each tester/build/device.
Record app version **and build number**, device, OS, horn configuration, appearance,
audio accessory/model, input selection and any independent pitch reference used.
Statuses are **Pass**, **Fail**, **Not run**, or **Not applicable** with a reason.
A development-build result does not count as a TestFlight pass.

Use written pitch names throughout. Middle C is C4. Baseline tuning is A4 = 440 Hz.
Start on the double horn in F/B♭ with built-in input/output. Test additional routes
only with available equipment; record missing equipment as Not run. Keep other
sound sources quiet for pitch checks. Screenshots establish UI state, not acoustic
accuracy. A horn alone cannot establish the tuner's absolute calibration.

## Coverage and order

Every tester runs the smoke test and the core instrument/tuner/metronome cases.
Distribute the remaining matrix across testers: iPhone and iPad, smallest supported
screen, oldest supported OS available, current OS, light/low light, large text,
VoiceOver, built-in audio, wired headphones, Bluetooth and USB input if available.
Include an upgrade from the last beta as well as a genuinely fresh installation.

**Smoke test, about 10 minutes:** APP-01, MUS-01, MUS-03, TUN-02, TUN-04, TUN-05,
MET-01, MET-02 and LIFE-01. Any crash, wrong pitch/octave/transposition, stuck
recording or unexpected playback is a release blocker. Stop that case, capture
the failure, and continue independent cases if possible.

## Installation and navigation

| ID | Steps | Expected result |
| --- | --- | --- |
| APP-01 | Launch the installed beta, select Double Horn in F/B♭ if prompted, visit all three tabs and open/close Settings. | Setup completes; Fingerings, Tuner and Metronome remain reachable; no crash or blocked navigation. |
| APP-02 | Upgrade an existing beta with a different selected horn, appearance and metronome settings; relaunch. | The saved instrument/appearance/tool and valid metronome choices survive. Output remains stopped. No unexpected permission prompt from general Settings. |
| APP-03 | Relaunch after force-quitting during reference or metronome playback. | No output restarts automatically. Saved choices restore without a stale playing indicator. |

## Musical identity and reference audio

| ID | Steps | Expected result |
| --- | --- | --- |
| MUS-01 | On Double Horn, select C5; compare both rows. Select C♯5, then switch to flats. | C5 shows two existing fingerings, C♯5/D♭5 three. Valve/trigger states remain the same between enharmonic spellings. Staff changes spelling correctly. First listed is not presented as universally preferred. |
| MUS-02 | For each of the eight configurations, select written C5, compare the written key and sounding label, then play the reference. | The Single Horn and Marching Horn choices marked “Music Written in B♭” sound B♭4 / 466.2 Hz (A♯4 in sharps). All other configurations use F notation and sound F4 / 349.2 Hz. Physical B♭ tubing on a double horn does not change its F notation. |
| MUS-03 | In F notation, hear written C4, C5 and C♯5. Compare with an independent reference if available. | Sounding pitches are F3 / 174.6 Hz, F4 / 349.2 Hz and F♯4 / 370.0 Hz, with the correct octaves. No doubled-frequency sampler regression. Log consistent cents offsets separately from octave/semitone identity. |
| MUS-04 | On Double Horn, choose C2 and C6, step toward each boundary, then switch to Single Horn in F or Marching Horn. | C2 has eight lower ledger lines and C6 the appropriate upper ledger lines; notation fits without clipping. Stepping beyond the range is disabled. Switching to a smaller range chooses a supported note. |
| MUS-05 | Start a reference, change the selected note, restart and change only sharp/flat spelling, then change instrument. Test explicit Stop too. | Note/instrument changes and Stop end playback promptly. Spelling alone preserves the same sounding tone. Starting again uses the current sounding pitch. No stuck note or overlapping sampler. |

## Microphone permission and tuner

| ID | Steps | Expected result |
| --- | --- | --- |
| TUN-01 | On an installation whose permission has not been decided, use Fingerings, Metronome and general Settings, then enter Tuner. | Output-only tools work without a microphone prompt. Tuner requests access when used. Allowing access starts capture. If permission was already decided, mark this fresh-prompt case Not run. |
| TUN-02 | With built-in input, sustain written C5 and D5 in F notation, then C4. | Written pitch and visible staff follow the actual notes in the right octave; sounding labels use the F transposition. No stable octave jump or frozen previous note. |
| TUN-03 | Sustain C5 and bend about 10–20 cents down, then up, staying within the same nearest note. | Flat/negative/left and Sharp/positive/right agree; C5 remains selected. In tune is within ±2 cents of the target. Words and signs work without relying on color. |
| TUN-04 | Stop a steady note in a quiet room. Play a different note during the hold interval; repeat and remain quiet. | The entire last result (pitch, staff, cents and needle) holds for about 1.5 seconds after the last valid detection, then clears. A new valid note replaces it immediately. Repeated silence does not extend the hold. Room noise above the threshold can produce a new reading; record sensitivity/input conditions. |
| TUN-05 | While a reading is live or held, Pause; play while paused; Resume. | Pause clears pitch/notehead/needle immediately, without waiting 1.5 seconds. It stays paused until Resume. Resume produces fresh measurements without relaunching. |
| TUN-06 | Deny microphone access, use reference and metronome, then enable microphone access in system Settings and return. | Denied state clears readings and offers Open Settings. Output-only tools still work. Returning after enabling access permits fresh capture. No prompt loop. |
| TUN-07 | Open Microphone & input settings, adjust sensitivity and select an available input; return to Tuner. | Input setup records only while needed. Raising the threshold excludes quieter noise; lowering it admits quieter notes. UI matches the selected input and no stale graph survives a change. |
| TUN-08 | If an independent calibrated source is available, play steady known pitches at several registers and compare measured frequency/cents after the attack. | Record signed error, source and room/input setup. Provisional beta target: within ±5 cents on a stable calibrated source after settling. Investigate repeated errors; do not substitute expressive horn bends or the app's own reference as independent calibration evidence. Otherwise Not run. |

## Lifecycle and interruptions

| ID | Steps | Expected result |
| --- | --- | --- |
| LIFE-01 | While listening, go Home for five seconds and return; play a different note. Repeat while paused. | Recording stops in background. Active intent recovers on return with a fresh note; paused intent remains paused. No held reading survives backgrounding. |
| LIFE-02 | Invoke Siri while listening, dismiss it and play C5 then D5. Repeat while paused. | Capture pauses during interruption. It resumes automatically when the OS permits, or a clear Resume Listening action recovers it. Paused intent is preserved. No frozen note or app relaunch needed. |
| LIFE-03 | Repeat LIFE-02 with a call or another real audio interruption, when available. | Same recovery policy. Record the interruption type and whether recovery was automatic or manual. Siri passing alone does not establish this result. |
| LIFE-04 | From active Tuner, open general Settings and return; change tabs and return. Repeat while paused. Open/close explicit input setup separately. | Covered tuner stops; active intent resumes on return, paused intent is preserved. General Settings does not acquire input; explicit input setup releases its lease on leaving. |
| LIFE-05 | Start reference/metronome output; test Settings, tab exit, backgrounding and Siri separately. | Output stops and its button returns to Play/Start. It does not restart automatically after interruption or return. |

## Routes: run each available accessory separately

Record headphone/interface model and whether it supplies a microphone. Keep other
accessories disconnected for each run. Use C5 then D5 after route changes so a
frozen reading cannot look like a successful recovery.

| ID | Steps | Expected result |
| --- | --- | --- |
| ROUTE-01 | Connect and remove wired headphones while the tuner listens; repeat while paused. | Active capture recovers once the route settles; paused intent remains paused. No stale reading during rebuild. Input returns to an available system route after removal. |
| ROUTE-02 | Connect and disconnect Bluetooth while listening; repeat while paused. | Same recovery/intent behavior. Record actual input where identifiable and any consistent delay, instability or pitch error. No relaunch needed. |
| ROUTE-03 | For wired and Bluetooth separately, start reference output through headphones, then disconnect them. Repeat with metronome. | Output stops and stays stopped until explicit restart. No unexpected continuation through speakers. Test actual disconnection, not just selecting another output. |
| ROUTE-04 | Select a USB microphone/interface in input setup, track notes, remove the preferred device and return to Tuner. | Missing preferred input falls back to the system default if usable. No usable input clears readings and offers recovery. Reconnecting and retrying works without relaunch. |

## Metronome

| ID | Steps | Expected result |
| --- | --- | --- |
| MET-01 | Start at 120; enter 96 by tapping the tempo number; use slider and ± while playing. Try 40 and 208. | Changes reach the running pulse without a second click stream, stop/restart or stuck transport. Boundaries disable further ± changes. |
| MET-02 | Open numeric tempo entry; try blank, 39 and 209; edit to 84; also edit and Cancel. | Invalid values cannot be applied; explanation is visible. 84 applies once. Cancel preserves the old tempo and playback state. Keyboard and actions remain reachable. |
| MET-03 | While playing, switch 2/4, 3/4, 4/4 and 6/8; toggle accent. | First click accents when enabled. Meter changes begin a new bar on the next click. 6/8 explicitly counts six eighth-note clicks at the displayed rate, not dotted quarters. |
| MET-04 | Tap a steady tempo several times; repeat while playing, after a long pause and after manual adjustment. | Tap tempo converges to the taps within 40–208. It never starts playback by itself or adds a second clock. A long pause/manual adjustment starts a fresh tap sequence. |
| MET-05 | Set 96, 3/4, accent off; terminate and relaunch the app. Start, stop and relaunch again. | Choices restore, with playback always stopped on launch. No reset to 120 or unintended auto-start. |
| MET-06 | Play for 10 minutes at 40, 137 and 208 across available testers; scroll and change controls during playback. | No audible dropouts, accumulating extra clicks, crash or UI freeze. Log device/output route. Listening is a dropout screen, not a laboratory timing measurement; sample timing has separate offline tests. |

## Readability and sustained use

| ID | Steps | Expected result |
| --- | --- | --- |
| UX-01 | Use each tool from a normal music-stand distance in light and low-light appearance, portrait and landscape. | Note/octave, staff, cents/direction and tempo remain readable; selectors and transport can be reached by scrolling without horizontal clipping. Record musician preference, not only visual approval. |
| UX-02 | Use the largest accessibility text size, VoiceOver, Reduce Motion and increased contrast where available. | Content wraps/scrolls; full spoken action names and valve states remain clear. Staff has a written-note description. Tuning changes do not spam unsolicited announcements. No essential status uses color alone. |
| UX-03 | Practice for 20 minutes, switching tools, suspending and returning, and changing instrument. | No crash, escalating latency, stuck recording/output or unexpected restart. Record thermal/battery observations with conditions; no battery-life claim from one run. |

## Triage and release decision

For each failure include case ID, exact steps, expected/actual result, reproducibility
(for example 3/3), build, OS, input/output route, screenshot/video and recovery used.
Avoid recording unrelated conversations in evidence. File one issue per distinct
failure and link duplicate reports. Use TestFlight feedback or the agreed project
issue tracker; this document does not send feedback automatically.

Before wider release: complete smoke coverage on phone and tablet; resolve crashes,
wrong musical identity and stuck/unexpected audio; repeat the affected cases on the
fixed build. List all Not run cases and coverage gaps explicitly. Bluetooth/USB and
older OS results must not be inferred from built-in audio or simulator passes.

Development-session evidence is in [the design record](../Design/DESIGN.md#physical-ipad-session--19-october-2026).
The octave correction, steady C5, direction, silence clearing, pause/background,
Siri and wired-headphone observations are useful baselines. Bluetooth, USB, fresh
permission, accessibility and the new 1.5-second hold/settings enhancements still
need the appropriate beta-build verification.
