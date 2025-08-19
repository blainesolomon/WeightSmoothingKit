import Testing
@testable import WeightSmoothingKit

struct WeightSmoothingKitTests {
    @Test
    func testMovingAverage_basic() {
        let v = [1, 2, 3, 4, 5]
        #expect(WeightSmoothing.movingAverage(v, window: 1) == v)
        #expect(WeightSmoothing.movingAverage(v, window: 2).map { round($0 * 100)/100 } == [1, 1.5, 2.5, 3.5, 4.5])
        #expect(WeightSmoothing.movingAverage(v, window: 3).map { round($0 * 100)/100 } == [1, 1.5, 2, 3, 4])
    }

    @Test
    func testEMA_monotonic() {
        let v = [100, 99, 98, 97, 96]
        let ema = WeightSmoothing.exponentialMovingAverage(v, window: 3)
        #expect(ema.count == v.count)
        // EMA should decrease and stay between min/max of prefix.
        for i in 1..<ema.count { #expect(ema[i] <= ema[i - 1]) }
        for i in ema.indices { #expect(ema[i] <= 100 && ema[i] >= 96) }
    }

    @Test
    func testMedianFilter_outlierSuppression() {
        let v = [150, 151, 400, 152, 153]
        let m = WeightSmoothing.medianFilter(v, window: 3)
        #expect(m[2] != 400) // center outlier is suppressed
    }

    @Test
    func testSlope_trendingUp() {
        let v = [1, 2, 3, 4, 5]
        let s = WeightSmoothing.slope(v, window: 5)
        #expect(s > 0.9 && s < 1.1) // approx 1 per step
    }
}
