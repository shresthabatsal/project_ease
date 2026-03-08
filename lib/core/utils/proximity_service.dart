import 'dart:async';
import 'dart:io';
import 'package:all_sensors/all_sensors.dart';
import 'package:flutter/material.dart';

class ProximityService {
  final VoidCallback onNear;
  final VoidCallback onFar;

  ProximityService({required this.onNear, required this.onFar});

  StreamSubscription<ProximityEvent>? _subscription;
  bool _started = false;
  bool _isNear = false;
  Timer? _startupIgnoreTimer;

  void start() {
    if (!Platform.isAndroid) return;

    _started = false;
    _isNear = false;

    _startupIgnoreTimer = Timer(const Duration(milliseconds: 500), () {
      _started = true;
    });

    _subscription = proximityEvents?.listen(
      (ProximityEvent event) {
        final bool near = event.getValue();
        debugPrint('🔵 Proximity near: $near, started: $_started');

        if (!_started) return;
        if (near == _isNear) return;
        _isNear = near;

        near ? onNear() : onFar();
      },
      onError: (e) {
        debugPrint('Proximity error: $e');
      },
    );
  }

  void stop() {
    _startupIgnoreTimer?.cancel();
    _subscription?.cancel();
    _startupIgnoreTimer = null;
    _subscription = null;
    _isNear = false;
    _started = false;
  }
}
