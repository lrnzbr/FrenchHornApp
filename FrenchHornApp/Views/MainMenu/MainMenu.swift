import SwiftUI

private enum PracticeTool: String, CaseIterable {
    case fingerings, tuner, metronome

    var title: String {
        switch self {
        case .fingerings: return "Fingerings"
        case .tuner: return "Tuner"
        case .metronome: return "Metronome"
        }
    }

    var symbol: String {
        switch self {
        case .fingerings: return "music.note.list"
        case .tuner: return "tuningfork"
        case .metronome: return "metronome"
        }
    }
}

struct MainMenu: View {
    var instrument: Instrument
    @StateObject private var viewModel = InstrumentViewModel.shared
    @AppStorage("adagio.selectedTool") private var selectedToolID = PracticeTool.fingerings.rawValue
    @State private var showingSettings = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var selectedTool: PracticeTool { PracticeTool(rawValue: selectedToolID) ?? .fingerings }
    private var currentInstrument: Instrument { viewModel.selectedInstrument ?? instrument }

    var body: some View {
        TabView(selection: Binding(get: { selectedTool }, set: { selectedToolID = $0.rawValue })) {
            destination(.fingerings) {
                FingeringChartView(instrument: currentInstrument,
                                   isActive: selectedTool == .fingerings && !showingSettings)
            }
            destination(.tuner) {
                TunerView(isActive: selectedTool == .tuner && !showingSettings)
            }
            destination(.metronome) {
                MetronomeView(isActive: selectedTool == .metronome && !showingSettings)
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingSettings = false }
                                .accessibilityIdentifier("settings.done")
                        }
                    }
            }
            .navigationViewStyle(.stack)
        }
    }

    private func destination<Content: View>(_ tool: PracticeTool, @ViewBuilder content: () -> Content) -> some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                if verticalSizeClass != .compact {
                    Text(tool.title)
                        .font(AdagioTheme.TypeStyle.screenTitle)
                        .padding(.horizontal, AdagioTheme.Space.xl)
                        .padding(.vertical, AdagioTheme.Space.sm)
                        .accessibilityAddTraits(.isHeader)
                }
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
                .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
                .navigationTitle(tool.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(verticalSizeClass == .compact ? tool.title : "adagio")
                            .font(verticalSizeClass == .compact ? .headline : AdagioTheme.TypeStyle.wordmark)
                            .fixedSize()
                            .foregroundColor(AdagioTheme.Colors.ink)
                            .accessibilityLabel(verticalSizeClass == .compact ? tool.title : "Adagio Studios")
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showingSettings = true } label: {
                            Image(systemName: "gearshape")
                                .frame(minWidth: AdagioTheme.Control.minimumTarget,
                                       minHeight: AdagioTheme.Control.minimumTarget)
                        }
                        .accessibilityLabel("Settings")
                        .accessibilityIdentifier("studio.settings.\(tool.rawValue)")
                    }
                }
        }
        .navigationViewStyle(.stack)
        .tabItem { Label(tool.title, systemImage: tool.symbol) }
        .tag(tool)
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu(instrument: instruments[1])
            .tint(AdagioTheme.Colors.accent)
            .foregroundColor(AdagioTheme.Colors.ink)
    }
}
