import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class ProximityService {
  final VoidCallback onNear;
  final VoidCallback onFar;

  ProximityService({required this.onNear, required this.onFar});

  StreamSubscription<int>? _subscription;
  bool _isNear = false;

  bool get isNear => _isNear;

  void start() {
    _subscription = ProximitySensor.events.listen((int event) {
      final near = event == 1;
      if (near == _isNear) return;
      _isNear = near;
      if (near) {
        onNear();
      } else {
        onFar();
      }
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _isNear = false;
  }
}
