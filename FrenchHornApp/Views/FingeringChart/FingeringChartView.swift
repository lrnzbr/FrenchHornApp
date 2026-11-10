import SwiftUI

struct FingeringChartView: View {
    let instrument: Instrument
    var isActive: Bool
    @State private var writtenMIDI: Int8 = 72
    @State private var prefersFlats = false
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    init(instrument: Instrument, isActive: Bool = true) {
        self.instrument = instrument
        self.isActive = isActive
    }

    // Keep only the user's choice in State. A cached Instrument here can survive a sheet/tab
    // transition and disagree with the new header before SwiftUI delivers onChange.
    private var selection: FingeringSelection {
        get { FingeringSelection(instrument: instrument, writtenMIDI: writtenMIDI, prefersFlats: prefersFlats) }
        nonmutating set {
            writtenMIDI = newValue.writtenMIDI ?? 72
            prefersFlats = newValue.prefersFlats
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AdagioTheme.Space.md) {
                Text(instrument.name)
                    .font(AdagioTheme.TypeStyle.support)
                    .foregroundColor(AdagioTheme.Colors.secondaryInk)
                if let note = selection.selectedNote {
                    notePanel(note)
                    if sizeCategory.isAccessibilityCategory {
                        VStack(alignment: .leading, spacing: AdagioTheme.Space.md) { notePicker; octavePicker }
                    } else {
                        HStack(spacing: AdagioTheme.Space.md) { notePicker; octavePicker }
                    }
                    alternateFingerings
                    DisclosureGroup("Hand & instrument guide") {
                        VStack {
                            Image(instrument.handImage).resizable().scaledToFit()
                            Image(instrument.instrumentGuideImage).resizable().scaledToFit()
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.white)
                    }
                    .font(AdagioTheme.TypeStyle.support)
                    .padding(.vertical, AdagioTheme.Space.sm)
                } else {
                    Text("No notes are available for this instrument.")
                }
            }
            .padding(.horizontal, AdagioTheme.Space.xl)
            .padding(.vertical, AdagioTheme.Space.md)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .safeAreaInset(edge: .bottom) {
            if let pitch = selection.soundingPitch, let sounding = selection.soundingNote {
                VStack(spacing: AdagioTheme.Space.sm) {
                    NoteSampler(pitch: pitch, isActive: isActive, contextID: instrument.id)
                    if verticalSizeClass != .compact {
                        Text(sizeCategory.isAccessibilityCategory ? "Sounding \(sounding.description)" : "Hear sounding \(sounding.description) · A4 = 440 Hz")
                            .font(.caption)
                            .foregroundColor(AdagioTheme.Colors.secondaryInk)
                    }
                }
                .padding(.horizontal, AdagioTheme.Space.lg)
                .padding(.vertical, verticalSizeClass == .compact ? AdagioTheme.Space.xs : AdagioTheme.Space.lg)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
                .background(AdagioTheme.Colors.canvas)
            }
        }
        .onChange(of: instrument.id) { _ in writtenMIDI = selection.writtenMIDI ?? 72 }
    }

    private func notePanel(_ note: Note) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("WRITTEN NOTE").foregroundColor(AdagioTheme.Colors.secondaryInk)
                Spacer()
                Text(selection.instrument.key == .F ? "Horn in F" : "Horn in B♭")
                    .foregroundColor(AdagioTheme.Colors.accent)
            }
            .font(.footnote)
            .padding(.horizontal, AdagioTheme.Space.lg)
            .padding(.top, AdagioTheme.Space.md)
            StaffPreview(note: note)
            Divider()
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading, spacing: AdagioTheme.Space.md) { soundingReadout; noteNavigation(note) }
                    .padding(AdagioTheme.Space.md)
            } else {
                HStack(spacing: 0) { soundingReadout; Spacer(minLength: 0); noteNavigation(note) }
                    .padding(.horizontal, AdagioTheme.Space.md)
                    .padding(.vertical, AdagioTheme.Space.xs)
            }
        }
        .background(AdagioTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AdagioTheme.Radius.panel))
        .overlay(RoundedRectangle(cornerRadius: AdagioTheme.Radius.panel)
            .strokeBorder(AdagioTheme.Colors.border, lineWidth: 1))
    }

    private var soundingReadout: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text("Sounds as").font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
            if let note = selection.soundingNote, let frequency = selection.frequency {
                Text("\(note.description) · \(frequency, specifier: "%.1f") Hz")
                    .font(.footnote.weight(.medium)).monospacedDigit()
                    .accessibilityLabel("Sounding note")
                    .accessibilityValue(Text(verbatim: String(format: "%@, %.1f Hz", note.description, frequency)))
                    .accessibilityIdentifier("fingerings.soundingPitch")
            }
        }
    }

    private func noteNavigation(_ note: Note) -> some View {
        HStack(spacing: 0) {
            Button { selection.step(-1) } label: {
                Image(systemName: "chevron.left").frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .accessibilityLabel("Previous note").accessibilityIdentifier("fingerings.previous")
            .disabled(!selection.canStep(-1))
            Text(note.description).font(.title2.weight(.medium)).monospacedDigit()
                .accessibilityLabel("Written note").accessibilityValue(note.description)
                .accessibilityIdentifier("fingerings.writtenPitch")
            Button { selection.step(1) } label: {
                Image(systemName: "chevron.right").frame(width: 44, height: 44).contentShape(Rectangle())
            }
            .accessibilityLabel("Next note").accessibilityIdentifier("fingerings.next")
            .disabled(!selection.canStep(1))
        }.buttonStyle(.plain)
    }

    private var notePicker: some View {
        selector("Note") {
            Menu {
                ForEach(selection.notesInOctave, id: \.noteNumber) { note in
                    Button(note.description) { selection.select(note.noteNumber) }
                }
            } label: { menuLabel(selection.selectedNote?.description ?? "—") }
            .accessibilityLabel("Note, \(selection.selectedNote?.description ?? "None")")
            .accessibilityIdentifier("fingerings.note")
        }
    }
    private var octavePicker: some View {
        selector("Octave") {
            Menu {
                ForEach(selection.octaves, id: \.self) { octave in
                    Button("\(octave)") { selection.selectOctave(octave) }
                }
            } label: { menuLabel(selection.selectedNote.map { String($0.octave) } ?? "—") }
            .accessibilityLabel("Octave, \(selection.selectedNote?.octave ?? 5)")
            .accessibilityIdentifier("fingerings.octave")
        }
    }

    private func menuLabel(_ value: String) -> some View {
        HStack {
            Text(value)
            Spacer(minLength: AdagioTheme.Space.sm)
            Image(systemName: "chevron.up.chevron.down").font(.caption).accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, minHeight: AdagioTheme.Control.minimumTarget)
        .contentShape(Rectangle())
    }
    private func selector<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text(title).font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
            content()
                .frame(maxWidth: .infinity, minHeight: AdagioTheme.Control.minimumTarget, alignment: .leading)
                .padding(.horizontal, AdagioTheme.Space.sm)
                .background(AdagioTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AdagioTheme.Radius.control))
                .overlay(RoundedRectangle(cornerRadius: AdagioTheme.Radius.control)
                    .strokeBorder(AdagioTheme.Colors.borderStrong, lineWidth: 1))
        }
    }

    private var alternateFingerings: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.sm) {
            if sizeCategory.isAccessibilityCategory {
                VStack(alignment: .leading, spacing: AdagioTheme.Space.md) { fingeringHeading; spellingButton }
            } else {
                HStack { fingeringHeading; Spacer(minLength: AdagioTheme.Space.sm); spellingButton }
            }
            VStack(spacing: 0) {
                ForEach(Array(selection.fingerings.enumerated()), id: \.offset) { index, fingering in
                    if index > 0 { Divider().padding(.horizontal, AdagioTheme.Space.md) }
                    FingeringRow(instrument: selection.instrument, fingering: fingering, index: index)
                }
            }
            .background(AdagioTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AdagioTheme.Radius.panel))
            .overlay(RoundedRectangle(cornerRadius: AdagioTheme.Radius.panel)
                .strokeBorder(AdagioTheme.Colors.border, lineWidth: 1))
            if instrument.hasTrigger1 {
                Text(instrument.hasTrigger2 ? "T / T2 = thumb triggers" : "T = thumb trigger")
                    .font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
            }
        }
    }

    private var fingeringHeading: some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.xs) {
            Text("Fingerings · \(selection.fingerings.count)").font(.headline)
                .accessibilityLabel("Available fingerings")
                .accessibilityValue(Text(verbatim: String(selection.fingerings.count)))
                .accessibilityIdentifier("fingerings.count")
            Text("● pressed · ○ released").font(.caption)
                .foregroundColor(AdagioTheme.Colors.secondaryInk)
        }
    }
    private var spellingButton: some View {
        Button(selection.prefersFlats ? "♭ Flats" : "♯ Sharps") { selection.prefersFlats.toggle() }
            .buttonStyle(AdagioSecondaryButtonStyle())
            .accessibilityLabel("Use \(selection.prefersFlats ? "sharps" : "flats")")
            .accessibilityIdentifier("fingerings.spelling")
    }
}

struct FingeringChartView_Previews: PreviewProvider {
    static var previews: some View {
        FingeringChartView(instrument: instruments[1], isActive: false)
            .foregroundColor(AdagioTheme.Colors.ink)
            .background(AdagioTheme.Colors.canvas)
    }
}
