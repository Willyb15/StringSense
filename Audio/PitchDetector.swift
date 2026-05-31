import Foundation
import Accelerate

// YIN pitch detection algorithm with vDSP acceleration.
// Reliable for guitar frequencies (80–1400 Hz) with low latency.
class PitchDetector {
    private let sampleRate: Float
    private let threshold: Float

    init(sampleRate: Float = 44100, threshold: Float = 0.15) {
        self.sampleRate = sampleRate
        self.threshold = threshold
    }

    func detectPitch(in buffer: [Float]) -> Float? {
        let n = buffer.count / 2
        guard n > 4 else { return nil }

        // Step 1: Difference function using vDSP (O(n) per tau via SIMD)
        var d = [Float](repeating: 0, count: n)
        var diff = [Float](repeating: 0, count: n)

        buffer.withUnsafeBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            for tau in 1..<n {
                // diff[j] = buffer[j] - buffer[j+tau]
                vDSP_vsub(base.advanced(by: tau), 1, base, 1, &diff, 1, vDSP_Length(n))
                // d[tau] = sum(diff^2)
                vDSP_svesq(diff, 1, &d[tau], vDSP_Length(n))
            }
        }

        // Step 2: Cumulative mean normalized difference (CMND)
        var cmnd = [Float](repeating: 1, count: n)
        var runningSum: Float = 0
        for tau in 1..<n {
            runningSum += d[tau]
            if runningSum > 0 {
                cmnd[tau] = d[tau] * Float(tau) / runningSum
            }
        }

        // Step 3: Find first tau below threshold (local minimum)
        var tau = 2
        while tau < n - 1 {
            if cmnd[tau] < threshold {
                while tau + 1 < n - 1 && cmnd[tau + 1] < cmnd[tau] {
                    tau += 1
                }
                break
            }
            tau += 1
        }

        guard tau < n - 1, cmnd[tau] < threshold else { return nil }

        // Step 4: Parabolic interpolation for sub-sample accuracy
        let s0 = cmnd[tau - 1], s1 = cmnd[tau], s2 = cmnd[tau + 1]
        let denom = 2 * (2 * s1 - s2 - s0)
        let refinedTau = denom == 0 ? Float(tau) : Float(tau) + (s2 - s0) / denom

        guard refinedTau > 0 else { return nil }
        return sampleRate / refinedTau
    }
}
