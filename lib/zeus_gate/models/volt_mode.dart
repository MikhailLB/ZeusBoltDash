enum VoltMode {
  web,
  game,
  fresh;

  String toKey() {
    switch (this) {
      case VoltMode.web:   return 'web';
      case VoltMode.game:  return 'game';
      case VoltMode.fresh: return 'fresh';
    }
  }

  static VoltMode fromKey(String? raw) {
    switch (raw) {
      case 'web': case 'browser': return VoltMode.web;
      case 'game': case 'arcade': return VoltMode.game;
      default: return VoltMode.fresh;
    }
  }
}
