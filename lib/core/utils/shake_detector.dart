import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final VoidCallback onShake;

  final double shakeThresholdG;

  final int minTimeBetweenShakesMs;

  ShakeDetector({
    required this.onShake,
    this.shakeThresholdG = 2.7,
    this.minTimeBetweenShakesMs = 1000,
  });

  StreamSubscription<AccelerometerEvent>? _subscription;
  int _lastShakeTime = 0;

  void start() {
    _subscription = accelerometerEventStream().listen(_onAccel);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onAccel(AccelerometerEvent event) {
    final double gForce = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (gForce - 9.8 > shakeThresholdG) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastShakeTime > minTimeBetweenShakesMs) {
        _lastShakeTime = now;
        onShake();
      }
    }
  }
}
