import SwiftUI
import AudioKitUI

struct SettingsView: View {
    @State private var isShowingInstrumentSheet = false
    @StateObject private var viewModel = InstrumentViewModel.shared
    @AppStorage("adagio.appearance") private var appearanceID = AdagioAppearance.system.rawValue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AdagioTheme.Space.xl) {
                section("Your instrument") {
                    if let instrument = viewModel.selectedInstrument {
                        InstrumentTabView(instrument: instrument)
                        Button("Change instrument") { isShowingInstrumentSheet = true }
                            .buttonStyle(AdagioSecondaryButtonStyle())
                            .accessibilityIdentifier("settings.instrument")
                    }
                }
                section("Appearance") {
                    Picker("Appearance", selection: $appearanceID) {
                        ForEach(AdagioAppearance.allCases) { appearance in
                            Text(appearance.title).tag(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(minHeight: AdagioTheme.Control.minimumTarget)
                    .accessibilityIdentifier("settings.appearance")
                }
                section("Audio") {
                    NavigationLink(destination: MicrophoneSettingsView()) {
                        HStack {
                            Label("Microphone & input", systemImage: "mic")
                            Spacer(minLength: AdagioTheme.Space.sm)
                            Image(systemName: "chevron.right").accessibilityHidden(true)
                        }.frame(minHeight: AdagioTheme.Control.minimumTarget)
                    }
                    .accessibilityIdentifier("settings.microphone")
                    Text("Choose an input and adjust sensitivity. Microphone access is requested only when you use the tuner or open input setup.")
                        .font(AdagioTheme.TypeStyle.support)
                        .foregroundColor(AdagioTheme.Colors.secondaryInk)
                }
                NavigationLink(destination: AboutView().navigationTitle("About")) {
                    HStack {
                        Label("About & support", systemImage: "info.circle")
                        Spacer(minLength: AdagioTheme.Space.sm)
                        Image(systemName: "chevron.right").accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, minHeight: AdagioTheme.Control.minimumTarget)
                }
                .adagioSurface()
            }
            .padding(AdagioTheme.Space.xl)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
        }
        .foregroundColor(AdagioTheme.Colors.ink)
        .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingInstrumentSheet) {
            ChangeHorn(isPresented: $isShowingInstrumentSheet)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AdagioTheme.Space.md) {
            Text(title).font(AdagioTheme.TypeStyle.sectionTitle).accessibilityAddTraits(.isHeader)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .adagioSurface()
    }
}

/// This explicit destination owns the settings recording lease, not the Settings sheet.
private struct MicrophoneSettingsView: View {
    @StateObject private var conductor = TunerConductor.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AdagioTheme.Space.xl) {
                MicrophoneStatusView(state: conductor.state, retry: conductor.retry)
                if let graph = conductor.graph {
                    InputDevicePicker(conductor: conductor)
                    NodeOutputView(graph.output).clipped()
                        .frame(height: 80)
                        .id(ObjectIdentifier(graph.engine))
                        .accessibilityHidden(true)
                    DisclosureGroup("Input diagnostics") {
                        VStack {
                            NodeRollingView(graph.waveform).frame(height: 80).clipped()
                            NodeFFTView(graph.spectrum).frame(height: 100).clipped()
                        }.accessibilityHidden(true)
                    }
                    .id(ObjectIdentifier(graph.engine))
                    .adagioSurface()
                }
                VStack(alignment: .leading, spacing: AdagioTheme.Space.md) {
                    Text("Microphone sensitivity").font(AdagioTheme.TypeStyle.sectionTitle)
                    Text("Raise the threshold to ignore more background noise.")
                        .font(AdagioTheme.TypeStyle.support)
                        .foregroundColor(AdagioTheme.Colors.secondaryInk)
                    Slider(value: $conductor.micSensitivity, in: 0...1)
                        .accessibilityLabel("Microphone sensitivity")
                        .accessibilityValue("\(Int(conductor.micSensitivity * 100)) percent")
                    Text(conductor.micSensitivity, format: .percent.precision(.fractionLength(0)))
                        .font(AdagioTheme.TypeStyle.label).monospacedDigit()
                }.adagioSurface()
            }.padding(AdagioTheme.Space.xl)
                .frame(maxWidth: 680).frame(maxWidth: .infinity)
        }
        .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
        .navigationTitle("Microphone & input")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { conductor.start(for: .settings) }
        .onDisappear { conductor.stop(for: .settings) }
    }
}

struct ChangeHorn: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = InstrumentViewModel.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AdagioTheme.Space.md) {
                    ForEach(instruments, id: \.id) { instrument in
                        Button {
                            viewModel.setSelectedInstrument(instrumentID: instrument.id)
                            isPresented = false
                        } label: {
                            HStack {
                                InstrumentTabView(instrument: instrument)
                                Spacer(minLength: AdagioTheme.Space.sm)
                                if viewModel.selectedInstrument?.id == instrument.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AdagioTheme.Colors.accent)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .adagioSurface()
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("instrument.\(instrument.id)")
                        .accessibilityAddTraits(viewModel.selectedInstrument?.id == instrument.id ? .isSelected : [])
                    }
                }.padding(AdagioTheme.Space.xl)
            }
            .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
            .navigationTitle("Choose your horn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }.navigationViewStyle(.stack)
    }
}
