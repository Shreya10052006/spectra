import 'dart:async';
import 'dart:math' as math;
import 'dart:collection';
import 'package:flutter/material.dart';
import '../services/backend_analytics_service.dart';

class WearableProvider with ChangeNotifier {
  Timer? _timer;
  final math.Random _random = math.Random();
  
  // Data State
  double _currentHeartRate = 75.0;
  final int _baseline = 75;
  final Queue<double> _heartRateHistory = Queue<double>();
  final int _historyLimit = 60; // Represents 60 data points across time
  
  // Triggers & Locks
  bool _isStressActive = false;
  bool _showBanner = false;
  bool _lockout = false; // Ensures "Single Notification Rule"

  double get currentHeartRate => _currentHeartRate;
  Queue<double> get heartRateHistory => _heartRateHistory;
  bool get isStressActive => _isStressActive;
  bool get showBanner => _showBanner;

  WearableProvider() {
    // Fill the initial chart so it isn't empty
    for (int i = 0; i < _historyLimit; i++) {
      _heartRateHistory.add(_baseline.toDouble());
    }
    _startSimulation();
  }

  void _startSimulation() {
    // Generate bio-metric data smoothly every 1.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isStressActive) {
        // Natural resting heart rate (smooth sine drift + micro random noise)
        final drift = (math.sin(timer.tick * 0.15) * 8) + (_random.nextDouble() * 4 - 2);
        _currentHeartRate = _baseline + drift; // generally stays 67-85
      } else {
        // Elevated state (Stress)
        _currentHeartRate = 118 + (_random.nextDouble() * 8.0); // 118-126
      }

      // Update Historical Array
      _heartRateHistory.add(_currentHeartRate);
      if (_heartRateHistory.length > _historyLimit) {
        _heartRateHistory.removeFirst();
      }

      // Detection Engine
      if (_currentHeartRate > _baseline + 30 && !_lockout) {
        _showBanner = true;
        _lockout = true; // Lock so no repeated alerts are ever sent
        
        // Log to Data Lake seamlessly
        BackendAnalyticsService.logWearableEvent(
          heartRate: _currentHeartRate.toInt(), 
          eventType: "spike", 
          userResponse: "auto_detected"
        );
      }

      notifyListeners();
    });
  }

  // --- External Controls (For UI and Demo) ---

  void triggerStressSpike() {
    _isStressActive = true;
    _showBanner = true;
    _lockout = true;
    
    BackendAnalyticsService.logWearableEvent(
      heartRate: 120, // baseline demo spike val
      eventType: "simulated_spike", 
      userResponse: "demo_triggered",
    );
    notifyListeners();
  }

  void resetSimulation() {
    _isStressActive = false;
    _showBanner = false;
    _lockout = false;
    notifyListeners();
  }

  void hideBanner() {
    _showBanner = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
