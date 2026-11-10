# French horn TestFlight build

Prepared 22 October 2026 for the existing Hornist's Almanac app, App Store ID
6462354990 and bundle ID `dev.lorenzobrown.FrenchHornApp`. The beta uses version
**1.3.0**, initially build **1**. Xcode may increase the upload build number to avoid
an existing build; record the number Apple actually receives before testing.

## Artifacts and provenance

Local artifacts are under the ignored `build/TestFlight/` directory:

- `FrenchHornApp-1.3.0-1.xcarchive`: signed Release archive and debug symbols.
- `Export-1.3.0-1/FrenchHornApp.ipa`: App Store distribution-signed export.
- `source-manifest-1.3.0-1.json`: SHA-256 hashes of project inputs and exported IPA.

The archive uses the current working tree, including the ongoing uncommitted
musical, audio and SwiftUI work. Base commit:
`8180f4a291268d9e6b6cb53b82b3d34da031c6cd`. That commit alone does not reproduce
this build; preserve the archive and source manifest together with the working
tree. No commit or tag was created as part of packaging.

The local IPA SHA-256 is
`3f92247640c54b1c41dd99659d20f03e6cccfd4aa9c7841827a8288979e3f3c6`.

## Release configuration

- Project build settings own version/build, expanded by `Info.plist`.
- Xcode Cloud changes only the build number; it preserves the marketing version.
- iPhone/iPad support and the iOS 15.5 deployment target are preserved.
- The packaged microphone purpose explains pitch detection.
- The app uses local settings and timing, without tracking or collected data.
  `PrivacyInfo.xcprivacy` declares `CA92.1` for app-only defaults and `35F9.1` for
  elapsed-time calculations/timers, as described in Apple's
  [required-reason API documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).
- The current app has no non-exempt encryption; its Info.plist declares this for
  export compliance. Reassess if encryption/network features are added.
- Export uses automatic App Store signing for team `L63W9QSW59`, with debugging
  disabled and beta reports enabled. Upload/export configuration keeps symbols.

## Reproduce packaging

Use the full Xcode toolchain and the shared `FrenchHornApp` scheme. With packages
resolved, archive the current tree:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project FrenchHornApp.xcodeproj -scheme FrenchHornApp \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/TestFlight/FrenchHornApp-1.3.0-1.xcarchive \
  -allowProvisioningUpdates archive
```

Choose a fresh archive path for another candidate. Do not overwrite a build being
tested. Export a local distribution IPA:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -exportArchive -archivePath build/TestFlight/FrenchHornApp-1.3.0-1.xcarchive \
  -exportPath build/TestFlight/Export-1.3.0-1 \
  -exportOptionsPlist Release/ExportOptions.plist -allowProvisioningUpdates
```

`Release/UploadOptions.plist` changes the destination to an App Store Connect
upload. Use it only for the candidate intended for beta distribution. An export
success alone does not mean Apple received or processed a build.

## Validation and device handoff

The signed Release archive and App Store IPA export passed. The IPA's bundle ID,
version/build, embedded App Store provisioning profile, disabled debugging,
privacy manifest, sampler resources/root key and code signature were checked.
All **76 Swift package regressions passed with Release optimization**, including
actual reference-sampler rendering, musical calculations, display hold and
metronome timing/settings. Cloud-script checks confirm numeric build updates,
stable marketing version and rejection of invalid build values.

The preceding implementation pass covered eleven iPhone and five affected iPad
UI scenarios across runs. These are simulator/development results, not a pass for
the distributed beta. Upload/processing status is recorded below when available.

### Upload status · 22 October 2026

Xcode's App Store Connect upload completed successfully for version **1.3.0
(build 1)**. Apple reported **“Uploaded package is processing”** and **“Upload
succeeded.”** Processing completion, tester-group availability and installation
have not yet been verified. The archive is open in Xcode Organizer for review.
The successful upload is not a completed device acceptance run.

App Store Connect: [French horn TestFlight](https://appstoreconnect.apple.com/apps/6462354990/testflight/ios).
The browser's App Store Connect page remained on its loading screen during the
initial upload session. The existing Xcode account handled signing and upload.

### Processing/access follow-up · 22 October 2026

App Store Connect now confirms that **1.3.0 (1) has finished processing**. Its
listed status is **Ready to Submit**, with expiry in 90 days. The build detail
page initially showed **Groups (0)** and **Individual Testers (0)**, so installation
access had not yet been assigned. Focused tuner/metronome instructions were saved
in What to Test; the page confirmed Saved.

### Internal access enabled · 23 October 2026

Following the owner's explicit approval, **Adagio iPad Testing** was created as an
internal testing group. App Store Connect confirms:

- Exactly **1 tester**: the owner's existing `lrnzbr@gmail.com` account, Lorenzo
  Brown. Status **Invited**, dated 23 October 2026. No other accounts were added.
- Exactly **1 build**: **1.3.0 (1)**, status **Testing**.
- Build Distribution: **Manual for Xcode Builds**. Automatic distribution is off.

The [internal group](https://appstoreconnect.apple.com/teams/2ca9d17b-d0de-48ca-8f09-a495aed8653a/apps/6462354990/testflight/groups/82aede80-8cde-4d08-8f67-9cf8c7c98a78/builds)
is open in the browser. Evidence is saved under `build/TestFlight/` in
`internal-group-testing-2026-10-23.jpg`, `internal-group-settings-2026-10-23.jpg`
and `internal-group-invited-2026-10-23.jpg`.

TestFlight installation on the physical iPad has not been verified; do not count
the older development install as a beta installation or acceptance result. The
owner must accept the invitation in TestFlight and install version 1.3.0 (1) on
the iPad before starting the beta checklist.

After installing the beta, use
[What to Test](../Testing/TESTFLIGHT_WHAT_TO_TEST.txt), the
[acceptance suite](../Testing/TESTFLIGHT_TEST_SUITE.md) and
[run template](../Testing/TESTFLIGHT_RUN_TEMPLATE.md). Prioritize TUN-04/TUN-05,
MET-01/MET-02/MET-05, then interruption/route recovery and fresh permission flows.
Record the installed version/build on each real device. An external testing group
may require Apple's beta review; uploading a build is not a public App Store
release.
