import SwiftUI

struct ChooseYourHorn: View {
    @StateObject private var viewModel = InstrumentViewModel.shared

    var body: some View {
        if let instrument = viewModel.selectedInstrument {
            MainMenu(instrument: instrument)
        } else {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: AdagioTheme.Space.xl) {
                        Text("Choose your horn")
                            .font(AdagioTheme.TypeStyle.screenTitle)
                            .accessibilityAddTraits(.isHeader)
                        Text("Choose the horn you play so notes and fingerings match your instrument.")
                            .font(AdagioTheme.TypeStyle.body)
                            .foregroundColor(AdagioTheme.Colors.secondaryInk)
                        ForEach(instruments, id: \.id) { instrument in
                            Button {
                                viewModel.setSelectedInstrument(instrumentID: instrument.id)
                            } label: {
                                InstrumentTabView(instrument: instrument)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .adagioSurface()
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("instrument.\(instrument.id)")
                        }
                    }.padding(AdagioTheme.Space.xl)
                }
                .background(AdagioTheme.Colors.canvas.ignoresSafeArea())
                .navigationTitle("Choose your horn")
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
        }
    }
}
