import Foundation

/// A bounded notation region, using the corrected diatonic position and ledger calculation.
struct StaffPreviewLayout {
    let visualization: TrebleClefNoteVisualization
    let top: CGFloat
    let bottom: CGFloat

    init(note: Note) {
        visualization = TrebleClefNoteVisualization(note: note)
        top = min(-54, visualization.notePosition - 20)
        bottom = max(54, visualization.notePosition + 20)
    }

    var height: CGFloat { bottom - top }
    var noteY: CGFloat { y(visualization.notePosition) }
    var staffLines: [CGFloat] { [-24, -12, 0, 12, 24].map { y($0) } }
    var ledgerLines: [CGFloat] { (visualization.ledgerLines ?? []).map { y($0.offset) } }
    func y(_ position: CGFloat) -> CGFloat { position - top }
}
