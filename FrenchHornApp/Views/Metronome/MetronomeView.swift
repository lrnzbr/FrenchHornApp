import SwiftUI

struct MetronomeView: View {
    var isActive = true
    @StateObject private var metronome = MetronomeController()
    @State private var tapTempo = TapTempo()
    @State private var showingTempoEntry = false
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        ScrollView {
            VStack(spacing: AdagioTheme.Space.xl) {
                VStack(spacing: AdagioTheme.Space.sm) {
                    Button { showingTempoEntry = true } label: {
                        VStack(spacing: AdagioTheme.Space.xs) {
                            AdagioMeasurement(value: String(format: "%.0f", metronome.bpm))
                            Label("Set tempo", systemImage: "pencil").font(.caption)
                                .foregroundColor(AdagioTheme.Colors.secondaryInk)
                        }.contentShape(Rectangle())
                    }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Tempo")
                        .accessibilityValue("\(Int(metronome.bpm)) \(metronome.meter.beatUnit)s per minute")
                        .accessibilityHint("Double tap to enter an exact tempo.")
                        .accessibilityIdentifier("metronome.tempo")
                    Text("\(metronome.meter == .sixEight ? "Eighth" : "Quarter") notes per minute")
                        .font(AdagioTheme.TypeStyle.support)
                        .foregroundColor(AdagioTheme.Colors.secondaryInk)
                        .accessibilityIdentifier("metronome.unit")
                }
                HStack(spacing: AdagioTheme.Space.lg) {
                    Button { setTempo(metronome.bpm - 1) } label: {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(AdagioSecondaryButtonStyle())
                    .accessibilityLabel("Decrease tempo")
                    .disabled(metronome.bpm <= MetronomeSettings.tempoRange.lowerBound)

                    Slider(value: Binding(get: { metronome.bpm }, set: { setTempo($0) }), in: MetronomeSettings.tempoRange, step: 1)
                        .accessibilityLabel("Tempo")
                        .accessibilityValue("\(Int(metronome.bpm)) \(metronome.meter.beatUnit)s per minute")

                    Button { setTempo(metronome.bpm + 1) } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(AdagioSecondaryButtonStyle())
                    .accessibilityLabel("Increase tempo")
                    .disabled(metronome.bpm >= MetronomeSettings.tempoRange.upperBound)
                }
                VStack(alignment: .leading, spacing: AdagioTheme.Space.sm) {
                    Text("Clicks per bar").font(.caption).foregroundColor(AdagioTheme.Colors.secondaryInk)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: sizeCategory.isAccessibilityCategory ? 64 : 36, maximum: 80))]) {
                        ForEach(0..<metronome.meter.beatsPerBar, id: \.self) { beat in
                            Text("\(beat + 1)")
                                .font(AdagioTheme.TypeStyle.support.weight(.medium))
                                .frame(minWidth: 32, minHeight: 32)
                                .foregroundColor(beat == 0 && metronome.accentFirstBeat ? AdagioTheme.Colors.accent : AdagioTheme.Colors.secondaryInk)
                                .background(Circle().fill(beat == 0 && metronome.accentFirstBeat ? AdagioTheme.Colors.accentMuted : AdagioTheme.Colors.surfaceMuted))
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(metronome.meter.beatsPerBar) clicks per bar\(metronome.accentFirstBeat ? ", first click accented" : "")")
                .accessibilityIdentifier("metronome.bar")
                VStack(alignment: .leading, spacing: AdagioTheme.Space.lg) {
                    HStack {
                        Text("Time signature")
                        Spacer(minLength: AdagioTheme.Space.sm)
                        Picker("Time signature", selection: $metronome.meter) {
                            ForEach(MetronomeMeter.allCases, id: \.self) { meter in
                                Text(meter.rawValue).tag(meter)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .accessibilityIdentifier("metronome.meter")
                        .frame(minHeight: AdagioTheme.Control.minimumTarget)
                    }
                    Divider()
                    Toggle("Accent first beat", isOn: $metronome.accentFirstBeat)
                        .accessibilityIdentifier("metronome.accent")
                        .toggleStyle(SwitchToggleStyle(tint: AdagioTheme.Colors.success))
                }.adagioSurface()
                Button {
                    if let tempo = tapTempo.tap(at: ProcessInfo.processInfo.systemUptime) { metronome.bpm = tempo }
                } label: {
                    Label("Tap tempo", systemImage: "hand.tap")
                        .frame(maxWidth: .infinity, minHeight: AdagioTheme.Control.minimumTarget)
                }
                .buttonStyle(AdagioSecondaryButtonStyle())
                .accessibilityHint("Tap at least twice to set the tempo. Each tap is one click, including an eighth note in 6/8.")
                .accessibilityIdentifier("metronome.tapTempo")
                if let message = metronome.errorMessage {
                    Text(message)
                        .foregroundColor(AdagioTheme.Colors.attention)
                        .font(AdagioTheme.TypeStyle.support)
                        .accessibilityIdentifier("metronome.error")
                }
            }
            .padding(AdagioTheme.Space.xl)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                if metronome.isPlaying { stop() }
                else if isActive { metronome.start() }
            } label: {
                Label(sizeCategory.isAccessibilityCategory ? (metronome.isPlaying ? "Stop" : "Start") : (metronome.isPlaying ? "Stop metronome" : "Start metronome"),
                      systemImage: metronome.isPlaying ? "stop.fill" : "play.fill")
            }
            .buttonStyle(AdagioPrimaryButtonStyle())
            .accessibilityLabel(metronome.isPlaying ? "Stop metronome" : "Start metronome")
            .accessibilityIdentifier("metronome.transport")
            .disabled(!isActive)
            .padding(.horizontal, AdagioTheme.Space.lg)
            .padding(.vertical, verticalSizeClass == .compact ? AdagioTheme.Space.xs : AdagioTheme.Space.lg)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
            .background(AdagioTheme.Colors.canvas)
        }
        .onChange(of: isActive) { active in
            if !active { stop() }
        }
        .sheet(isPresented: $showingTempoEntry) {
            MetronomeTempoEntryView(initialTempo: metronome.bpm, beatUnit: metronome.meter.beatUnit) { setTempo($0) }
        }
        .stopPlaybackOnAudioChange(perform: stop)
    }

    private func setTempo(_ value: Double) {
        tapTempo.reset()
        metronome.bpm = max(MetronomeSettings.tempoRange.lowerBound, min(MetronomeSettings.tempoRange.upperBound, value))
    }
    private func stop() { metronome.stop(); tapTempo.reset() }
}

private struct MetronomeTempoEntryView: View {
    let beatUnit: String
    let apply: (Double) -> Void
    @State private var text: String
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss

    init(initialTempo: Double, beatUnit: String, apply: @escaping (Double) -> Void) {
        self.beatUnit = beatUnit
        self.apply = apply
        _text = State(initialValue: String(format: "%.0f", initialTempo))
    }

    private var value: Double? { MetronomeTempoEntry.tempo(from: text) }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AdagioTheme.Space.lg) {
                    Text("\(beatUnit.capitalized)s per minute").font(.headline)
                    TextField("40–208", text: $text)
                        .font(.largeTitle.monospacedDigit())
                        .keyboardType(.numberPad)
                        .focused($focused)
                        .submitLabel(.done)
                        .onSubmit(commit)
                        .accessibilityLabel("Tempo")
                        .accessibilityIdentifier("metronome.tempoEntry")
                        .adagioSurface()
                    Text("Enter a whole-number tempo from 40 to 208.")
                        .font(.callout)
                        .foregroundColor(value == nil && !text.isEmpty ? AdagioTheme.Colors.attention : AdagioTheme.Colors.secondaryInk)
                }
                .padding(AdagioTheme.Space.xl)
                .frame(maxWidth: 680).frame(maxWidth: .infinity)
            }
            .foregroundColor(AdagioTheme.Colors.ink)
            .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
            .navigationTitle("Set tempo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.accessibilityIdentifier("metronome.tempoEntry.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Set tempo", action: commit).disabled(value == nil)
                        .accessibilityIdentifier("metronome.tempoEntry.save")
                }
            }
        }.navigationViewStyle(.stack)
            .onAppear { focused = true }
    }

    private func commit() {
        guard let value = value else { return }
        apply(value)
        dismiss()
    }
}

struct MetronomeView_Previews: PreviewProvider {
    static var previews: some View { MetronomeView(isActive: false) }
}
