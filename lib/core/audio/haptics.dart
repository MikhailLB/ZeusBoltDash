import 'package:flutter/services.dart';
import '../storage/profile_store.dart';

/// Thin wrapper over Flutter's built-in [HapticFeedback].
///
/// Replaces the third-party `vibration` plugin entirely — every cue maps to a
/// platform haptic primitive and is gated by the player's preference.
class Haptics {
  Haptics._();

  static bool get _enabled => ProfileStore.instance.profile.hapticsEnabled;

  /// A crisp tap — used for ordinary parries.
  static void parry() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  /// A heavier strike — used for perfect parries / reflects.
  static void perfect() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  /// The strongest cue — ultimate release and titan defeat.
  static void surge() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  /// Negative feedback — a guard break / damage taken.
  static void wound() {
    if (_enabled) HapticFeedback.lightImpact();
  }
}
