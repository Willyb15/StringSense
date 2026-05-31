import Foundation

struct GuitarString: Identifiable, Equatable {
    let id = UUID()
    let noteName: String
    let stringNumber: Int  // 1 = highest (e), 6 = lowest (E)
    var targetFrequency: Float { Note.frequency(for: noteName) }

    static func == (lhs: GuitarString, rhs: GuitarString) -> Bool { lhs.id == rhs.id }
}

struct TuningPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    // Index 0 = string 6 (lowest), index 5 = string 1 (highest)
    let strings: [GuitarString]

    var stringsHighToLow: [GuitarString] {
        strings.sorted { $0.stringNumber < $1.stringNumber }
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: TuningPreset, rhs: TuningPreset) -> Bool { lhs.id == rhs.id }

    static let all: [TuningPreset] = [
        TuningPreset(
            name: "Standard",
            description: "E A D G B e",
            strings: [
                GuitarString(noteName: "E2", stringNumber: 6),
                GuitarString(noteName: "A2", stringNumber: 5),
                GuitarString(noteName: "D3", stringNumber: 4),
                GuitarString(noteName: "G3", stringNumber: 3),
                GuitarString(noteName: "B3", stringNumber: 2),
                GuitarString(noteName: "E4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Drop D",
            description: "D A D G B e",
            strings: [
                GuitarString(noteName: "D2", stringNumber: 6),
                GuitarString(noteName: "A2", stringNumber: 5),
                GuitarString(noteName: "D3", stringNumber: 4),
                GuitarString(noteName: "G3", stringNumber: 3),
                GuitarString(noteName: "B3", stringNumber: 2),
                GuitarString(noteName: "E4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Open G",
            description: "D G D G B D",
            strings: [
                GuitarString(noteName: "D2", stringNumber: 6),
                GuitarString(noteName: "G2", stringNumber: 5),
                GuitarString(noteName: "D3", stringNumber: 4),
                GuitarString(noteName: "G3", stringNumber: 3),
                GuitarString(noteName: "B3", stringNumber: 2),
                GuitarString(noteName: "D4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Open D",
            description: "D A D F# A D",
            strings: [
                GuitarString(noteName: "D2", stringNumber: 6),
                GuitarString(noteName: "A2", stringNumber: 5),
                GuitarString(noteName: "D3", stringNumber: 4),
                GuitarString(noteName: "F#3", stringNumber: 3),
                GuitarString(noteName: "A3", stringNumber: 2),
                GuitarString(noteName: "D4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "DADGAD",
            description: "D A D G A D",
            strings: [
                GuitarString(noteName: "D2", stringNumber: 6),
                GuitarString(noteName: "A2", stringNumber: 5),
                GuitarString(noteName: "D3", stringNumber: 4),
                GuitarString(noteName: "G3", stringNumber: 3),
                GuitarString(noteName: "A3", stringNumber: 2),
                GuitarString(noteName: "D4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Open E",
            description: "E B E G# B E",
            strings: [
                GuitarString(noteName: "E2", stringNumber: 6),
                GuitarString(noteName: "B2", stringNumber: 5),
                GuitarString(noteName: "E3", stringNumber: 4),
                GuitarString(noteName: "G#3", stringNumber: 3),
                GuitarString(noteName: "B3", stringNumber: 2),
                GuitarString(noteName: "E4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Half Step Down",
            description: "Eb Ab Db Gb Bb Eb",
            strings: [
                GuitarString(noteName: "Eb2", stringNumber: 6),
                GuitarString(noteName: "Ab2", stringNumber: 5),
                GuitarString(noteName: "Db3", stringNumber: 4),
                GuitarString(noteName: "Gb3", stringNumber: 3),
                GuitarString(noteName: "Bb3", stringNumber: 2),
                GuitarString(noteName: "Eb4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Full Step Down",
            description: "D G C F A D",
            strings: [
                GuitarString(noteName: "D2", stringNumber: 6),
                GuitarString(noteName: "G2", stringNumber: 5),
                GuitarString(noteName: "C3", stringNumber: 4),
                GuitarString(noteName: "F3", stringNumber: 3),
                GuitarString(noteName: "A3", stringNumber: 2),
                GuitarString(noteName: "D4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Open A",
            description: "E A E A C# E",
            strings: [
                GuitarString(noteName: "E2", stringNumber: 6),
                GuitarString(noteName: "A2", stringNumber: 5),
                GuitarString(noteName: "E3", stringNumber: 4),
                GuitarString(noteName: "A3", stringNumber: 3),
                GuitarString(noteName: "C#4", stringNumber: 2),
                GuitarString(noteName: "E4", stringNumber: 1),
            ]
        ),
        TuningPreset(
            name: "Drop C",
            description: "C G C F A D",
            strings: [
                GuitarString(noteName: "C2", stringNumber: 6),
                GuitarString(noteName: "G2", stringNumber: 5),
                GuitarString(noteName: "C3", stringNumber: 4),
                GuitarString(noteName: "F3", stringNumber: 3),
                GuitarString(noteName: "A3", stringNumber: 2),
                GuitarString(noteName: "D4", stringNumber: 1),
            ]
        ),
    ]
}
