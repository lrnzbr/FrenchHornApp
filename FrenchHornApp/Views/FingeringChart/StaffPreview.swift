import SwiftUI

/// Vector lines/notehead and the existing template clef stay legible in both appearances.
struct StaffPreview: View {
    let note: Note?
    var accessibilityID = "fingerings.staff"
    // An empty tuner still shows the clef/staff, without inventing a detected note.
    private var layout: StaffPreviewLayout { StaffPreviewLayout(note: note ?? B4) }

    var body: some View {
        GeometryReader { geometry in
            let noteX = geometry.size.width * 0.64
            ZStack(alignment: .topLeading) {
                Path { path in
                    for y in layout.staffLines {
                        path.move(to: CGPoint(x: 16, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width - 16, y: y))
                    }
                }.stroke(AdagioTheme.Colors.secondaryInk, lineWidth: 0.8)
                Image("treble_clef")
                    .renderingMode(.template)
                    .resizable().scaledToFit()
                    .foregroundColor(AdagioTheme.Colors.ink)
                    .frame(width: 52, height: 84)
                    // The spiral of the G clef sits on the G4 line (+12 from B4).
                    .position(x: 46, y: layout.y(12) - 11)
                Path { path in
                    for y in layout.ledgerLines {
                        path.move(to: CGPoint(x: noteX - 20, y: y))
                        path.addLine(to: CGPoint(x: noteX + 20, y: y))
                    }
                }.stroke(AdagioTheme.Colors.ink, lineWidth: 1.3)
                if let note = note {
                    Ellipse().fill(AdagioTheme.Colors.surface)
                        .overlay(Ellipse().strokeBorder(AdagioTheme.Colors.ink, lineWidth: 2.8))
                        .frame(width: 24, height: 14)
                        .rotationEffect(.degrees(-15))
                        .position(x: noteX, y: layout.noteY)
                    if note.accidental != .natural {
                        Text(note.accidental.description)
                            .font(.system(size: 28, design: .serif))
                            .foregroundColor(AdagioTheme.Colors.ink)
                            .position(x: noteX - 29, y: layout.noteY - 3)
                    }
                }
            }
        }
        .frame(height: layout.height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(note.map { "Written \($0.description), treble clef, \(layout.ledgerLines.count) ledger lines" }
            ?? "Written staff, treble clef, no note detected")
        .accessibilityIdentifier(accessibilityID)
    }
}

struct StaffPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            sample(C5).previewDisplayName("C5")
            sample(C2).previewDisplayName("Low C2 · ledger lines")
            sample(DFlat6).preferredColorScheme(.dark).previewDisplayName("D♭6 · low light")
        }.previewLayout(.sizeThatFits)
    }
    private static func sample(_ note: Note) -> some View {
        StaffPreview(note: note).padding().background(AdagioTheme.Colors.surface)
    }
}
