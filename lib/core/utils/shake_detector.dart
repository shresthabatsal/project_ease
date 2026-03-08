import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final VoidCallback onShake;
  final double shakeThresholdG;
  final int minTimeBetweenShakesMs;
  final int requiredSamples;
  final int windowMs;

  ShakeDetector({
    required this.onShake,
    this.shakeThresholdG = 3.2,
    this.minTimeBetweenShakesMs = 1500,
    this.requiredSamples = 2,
    this.windowMs = 600,
  });

  StreamSubscription<AccelerometerEvent>? _subscription;
  int _lastShakeTime = 0;

  final List<int> _spikeTimes = [];

  void start() {
    _spikeTimes.clear();
    _subscription = accelerometerEventStream().listen(_onAccel);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _spikeTimes.clear();
  }

  void _onAccel(AccelerometerEvent event) {
    final double gForce = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (gForce - 9.8 > shakeThresholdG) {
      final now = DateTime.now().millisecondsSinceEpoch;

      _spikeTimes.add(now);
      _spikeTimes.removeWhere((t) => now - t > windowMs);

      if (_spikeTimes.length >= requiredSamples &&
          now - _lastShakeTime > minTimeBetweenShakesMs) {
        _lastShakeTime = now;
        _spikeTimes.clear();
        onShake();
      }
    }
  }
}
