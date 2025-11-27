import 'package:flutter/foundation.dart';

class OnboardingViewModel extends ChangeNotifier {
  static const int totalSteps = 3;

  int _currentStep = 0;
  bool _hasCompleted = false;

  int get currentStep => _currentStep;
  bool get hasCompleted => _hasCompleted;

  void next() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    } else {
      complete();
    }
  }

  void back() {
    if (_currentStep == 0) return;
    _currentStep--;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps && step != _currentStep) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void skip() => complete();

  void complete() {
    if (_hasCompleted) return;
    _hasCompleted = true;
    notifyListeners();
  }
}
