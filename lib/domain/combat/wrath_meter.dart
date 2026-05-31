/// Charge meter for a deity's ultimate ("Wrath").
///
/// Fills through successful parries and decays very slowly while idle so the
/// player is rewarded for sustained pressure rather than turtling.
class WrathMeter {
  double _value = 0; // 0..1
  bool _ready = false;

  double get value => _value;
  bool get isReady => _ready;

  void add(double amount) {
    if (_ready) return;
    _value += amount;
    if (_value >= 1) {
      _value = 1;
      _ready = true;
    }
  }

  /// Gentle idle decay (per second) until ready.
  void decay(double dt, {double rate = 0.012}) {
    if (_ready) return;
    _value = (_value - rate * dt).clamp(0, 1);
  }

  /// Spends the charge to unleash the ultimate. Returns false if not ready.
  bool consume() {
    if (!_ready) return false;
    _value = 0;
    _ready = false;
    return true;
  }

  void reset() {
    _value = 0;
    _ready = false;
  }
}
