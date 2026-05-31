# StringSense — Guitar Tuner App

A guitar tuner iOS app with chromatic pitch detection, alternate tunings, metronome, and practice timer.

## Features
- **Chromatic tuner** — YIN algorithm pitch detection via AVAudioEngine, accurate to ±1 cent
- **Guided string mode** — tap a string to tune it individually; ignores out-of-range noise
- **Pitch smoothing** — 4-frame rolling average removes jitter
- **Haptic feedback** — double-pulse when a string locks in tune
- **10 tuning presets** — Standard, Drop D, Open G, Open D, DADGAD, Open E, Open A, Half Down, Full Down, Drop C
- **Metronome** — tap tempo, accent on beat 1, 2/3/4/6 time signatures, Italian tempo markings
- **Practice timer** — progress ring, goal setting, pause/resume

## Setup in Xcode

### 1. Create the Xcode project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Set:
   - **Product Name**: StringSense
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Bundle Identifier**: com.yourname.stringsense
4. Choose a location to save (**not** inside this folder)

### 2. Add the source files

In Finder, drag the following folders into your Xcode project navigator (check "Copy items if needed"):
- `Audio/`
- `Models/`
- `ViewModels/`
- `Views/`

Replace the default `ContentView.swift` with the one from `Views/ContentView.swift`, and replace `YourAppNameApp.swift` with `GuitarTunerApp.swift` (update the `@main` struct name if needed).

### 3. Add microphone permission

In Xcode, select your project → **Info** tab → add a new row:

| Key | Value |
|-----|-------|
| Privacy - Microphone Usage Description | StringSense needs microphone access to detect your guitar pitch. |

Or edit `Info.plist` directly:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>StringSense needs microphone access to detect your guitar pitch.</string>
```

### 4. Build & run

Select your iPhone or simulator and press **⌘R**.

> **Note:** Pitch detection requires a real device — the simulator microphone is unreliable for audio processing.

## Architecture

```
Audio/
  PitchDetector.swift     YIN algorithm with Accelerate/vDSP
  AudioEngine.swift       AVAudioEngine mic capture
  MetronomeAudio.swift    Synthesized click tones

Models/
  Note.swift              Frequency → note name + cents deviation
  TuningPreset.swift      10 alternate tuning presets

ViewModels/
  TunerViewModel.swift    Pitch pipeline, haptics, string selection
  MetronomeViewModel.swift Beat scheduling, tap tempo

Views/
  TunerView.swift         Main tuner screen
  TunerMeterView.swift    Semicircular needle meter (SwiftUI Canvas)
  TuningPresetsView.swift Preset sheet
  MetronomeView.swift     Metronome screen
  PracticeTimerView.swift Timer screen
  ContentView.swift       Tab container
```

## How YIN works

YIN is a fundamental frequency estimator that:
1. Computes the **difference function** — how similar the signal is to a time-shifted copy of itself
2. Normalises it (**CMND**) to avoid bias toward small lags
3. Finds the first lag below a confidence threshold (0.15)
4. Uses **parabolic interpolation** for sub-sample accuracy

This gives ±1 cent accuracy across the guitar's full range (~80–1400 Hz) with ~10ms latency.
