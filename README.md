# WeightSmoothingKit

A tiny Swift Package with pragmatic smoothing utilities for weight trends:
- Causal **moving average**
- **Exponential moving average** (EMA)
- Quick **median filter** for outlier suppression
- Lightweight **slope** estimator (least squares) over the most recent window

Designed to be readable, testable, and easy to drop into an iOS app.

## Why this exists
Real-world weight logs have noise and outliers. These one-file utilities make it trivial to get stable trends and a simple slope signal, without pulling in heavy dependencies.
