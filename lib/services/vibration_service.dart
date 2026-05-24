import 'package:vibration/vibration.dart';
import 'storage_service.dart';

class VibrationService {
  static VibrationService? _instance;
  static VibrationService get instance => _instance ??= VibrationService._();
  VibrationService._();

  bool _hasVibrator = false;

  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator() == true;
  }

  bool get _enabled => StorageService.instance.getVibration();

  void collectLight() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 30, amplitude: 80);
  }

  void collectCoin() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 20, amplitude: 60);
  }

  void rockDamage() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 200, amplitude: 255);
  }

  void gameOver() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400]);
  }

  void coinModeStart() {
    if (!_enabled || !_hasVibrator) return;
    Vibration.vibrate(duration: 100, amplitude: 150);
  }
}
