import Foundation
import CoreHaptics
import SwiftUI

@MainActor
class TunerViewModel: ObservableObject {
    @Published var detectedNote: Note?
    @Published var detectedFrequency: Float?
    @Published var selectedTuning: TuningPreset = TuningPreset.all[0] {
        didSet {
            if oldValue.id != selectedTuning.id {
                selectedString = nil
                tunedStrings = []
            }
        }
    }
    @Published var selectedString: GuitarString?
    @Published var isListening = false
    @Published var permissionDenied = false
    @Published var autoMode = true
    @Published var tunedStrings: Set<UUID> = []

    // Running average to smooth pitch readings
    private var frequencyHistory: [Float] = []
    private let historySize = 4

    private let audioEngine = AudioEngine()
    private var hapticEngine: CHHapticEngine?
    private var wasInTune = false

    init() {
        setupHaptics()
        audioEngine.onPitchDetected = { [weak self] freq in
            Task { @MainActor [weak self] in
                self?.handleFrequency(freq)
            }
        }
    }

    func toggleListening() {
        if isListening {
            audioEngine.stop()
            isListening = false
            detectedNote = nil
            detectedFrequency = nil
            frequencyHistory = []
            tunedStrings = []
        } else {
            audioEngine.requestPermissionAndStart { [weak self] granted in
                Task { @MainActor [weak self] in
                    if granted {
                        self?.isListening = true
                    } else {
                        self?.permissionDenied = true
                    }
                }
            }
        }
    }

    var targetFrequency: Float? {
        selectedString?.targetFrequency
    }

    var guidedMode: Bool { selectedString != nil }

    private func handleFrequency(_ freq: Float) {
        frequencyHistory.append(freq)
        if frequencyHistory.count > historySize {
            frequencyHistory.removeFirst()
        }
        let smoothed = frequencyHistory.reduce(0, +) / Float(frequencyHistory.count)

        if autoMode, let closest = selectedTuning.strings.min(by: {
            abs($0.targetFrequency - smoothed) < abs($1.targetFrequency - smoothed)
        }) {
            let ratio = smoothed / closest.targetFrequency
            if ratio > 0.8 && ratio < 1.25 { selectedString = closest }
        }

        let note: Note?
        if let target = targetFrequency {
            let ratio = smoothed / target
            if ratio > 0.8 && ratio < 1.25 {
                note = Note.from(frequency: smoothed)
            } else {
                note = nil
            }
        } else {
            note = Note.from(frequency: smoothed)
        }

        detectedNote = note
        detectedFrequency = note != nil ? smoothed : nil

        if let note, note.tuningState == .inTune {
            if let string = selectedString { tunedStrings.insert(string.id) }
            if !wasInTune { triggerHaptic() }
        }
        wasInTune = note?.tuningState == .inTune
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        hapticEngine = try? CHHapticEngine()
        try? hapticEngine?.start()
    }

    private func triggerHaptic() {
        guard let engine = hapticEngine else { return }
        let events: [CHHapticEvent] = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4),
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
                ],
                relativeTime: 0.1
            ),
        ]
        guard let pattern = try? CHHapticPattern(events: events, parameters: []),
              let player = try? engine.makePlayer(with: pattern) else { return }
        try? player.start(atTime: 0)
    }
}
