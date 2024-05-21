//
//  SettingsView.swift
//  FrenchHornApp
//
//  Created by Lorenzo Brown on 7/3/23.
//

import SwiftUI
import AudioKitUI


struct SettingsView: View {
    @State var isShowingInstrumentSheet = false
    @StateObject private var viewModel = InstrumentViewModel.shared
    @State private var isEditing = false
    @StateObject private var conductor = TunerConductor.shared


    var body: some View {
        VStack {
            Text("Settings")
                .font(AppFont.title1).bold()
            Text("Your Instrument: ")
                .font(AppFont.title2).bold()

                Image(viewModel.selectedInstrument!.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120)
            Text(viewModel.selectedInstrument!.name)
                .font(AppFont.body)
                .padding()

            Button("Change Instrument"){
                isShowingInstrumentSheet.toggle()
            }
            Spacer()
            VStack {
                Text("Microphone Input: ")
                InputDevicePicker(device: conductor.initialDevice)
                NodeOutputView(conductor.tappableNodeB).clipped()
                    .frame(maxHeight: 80)

            }.onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
            .padding()
            VStack{
                Text("Microphone Sensitivity")
                    .font(AppFont.body)
                Text("Adjust sensitivity to background noise to prevent random / fluctuating data.")
                    .font(AppFont.caption1)
                    .multilineTextAlignment(.center)
                Slider(
                    value: $conductor.micSensitivity,
                    in: 0...1,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                )
                Text("\(conductor.micSensitivity)")
                    .foregroundColor(isEditing ? .red : .blue)
            }


            Spacer()
        }
        .padding()
        .sheet(isPresented: $isShowingInstrumentSheet) {
            ChangeHorn(isPresented: $isShowingInstrumentSheet)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct ChangeHorn: View {
    @Binding var isPresented:Bool
    @StateObject private var viewModel = InstrumentViewModel.shared

    func setSelectedInstrument(instrument:Instrument){
        viewModel.setSelectedInstrument(instrumentID: instrument.id)
        isPresented.toggle()
    }

    var body: some View {
        VStack{
            Text("Change Your Horn")
                .font(AppFont.title1).bold()
                .padding()
            List {
                ForEach(instruments, id: \.self) { instrument in
                    InstrumentTabView(instrument: instrument)
                        .onTapGesture {
                            setSelectedInstrument(instrument: instrument)
                        }
                }
            }
        }

    }
}

