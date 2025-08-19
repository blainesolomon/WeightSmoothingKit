public enum WeightSmoothing {
    /// Causal simple moving average. For the first `window-1` entries, averages over the prefix available.
    /// Window must be ≥ 1.
    @inlinable
    public static func movingAverage(_ values: [Double], window: Int) -> [Double] {
        guard window > 0 else { return values }
        guard !values.isEmpty else { return [] }

        var result = Array(repeating: 0.0, count: values.count)
        var sum = 0.0
        var q: [Double] = []
        q.reserveCapacity(window)

        for i in values.indices {
            let v = values[i]
            sum += v
            q.append(v)
            if q.count > window {
                sum -= q.removeFirst()
            }
            result[i] = sum / Double(q.count)
        }
        return result
    }

    /// Exponential moving average using alpha = 2/(window+1).
    /// For the first element, EMA equals the value.
    /// Window must be ≥ 1.
    @inlinable
    public static func exponentialMovingAverage(_ values: [Double], window: Int) -> [Double] {
        guard window > 0 else { return values }
        guard !values.isEmpty else { return [] }

        let alpha = 2.0 / (Double(window) + 1.0)
        var result = Array(repeating: 0.0, count: values.count)
        var ema = values[0]
        result[0] = ema

        if values.count > 1 {
            for i in 1..<values.count {
                ema = alpha * values[i] + (1 - alpha) * ema
                result[i] = ema
            }
        }
        return result
    }

    /// Small helper to compute a robust median filter (odd window only).
    /// Useful for quick outlier suppression before smoothing.
    @inlinable
    public static func medianFilter(_ values: [Double], window: Int) -> [Double] {
        guard window > 0, window % 2 == 1 else { return values }
        guard !values.isEmpty else { return [] }

        let k = window / 2
        var result = Array(repeating: 0.0, count: values.count)

        for i in values.indices {
            let start = max(0, i - k)
            let end = min(values.count - 1, i + k)
            var slice = Array(values[start...end])
            slice.sort()
            result[i] = slice[slice.count / 2]
        }
        return result
    }

    /// Lightweight slope (per-sample) over the last `window` points using least squares.
    /// Returns 0 for insufficient data.
    @inlinable
    public static func slope(_ values: [Double], window: Int) -> Double {
        guard window > 1, values.count >= 2 else { return 0 }
        let n = min(window, values.count)
        let start = values.count - n
        // x = 0..n-1
        let sumX = Double((n - 1) * n) / 2.0
        let sumX2 = Double((n - 1) * n * (2 * n - 1)) / 6.0
        var sumY = 0.0
        var sumXY = 0.0
        for i in 0..<n {
            let x = Double(i)
            let y = values[start + i]
            sumY += y
            sumXY += x * y
        }
        let denom = Double(n) * sumX2 - sumX * sumX
        return denom == 0 ? 0 : (Double(n) * sumXY - sumX * sumY) / denom
    }
}
