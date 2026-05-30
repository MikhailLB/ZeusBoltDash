import 'package:flutter/material.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../core/audio/haptics.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../sanctuary/legal.dart';
import '../widgets/sky_backdrop.dart';

/// Settings: haptics toggle and the required legal links.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _haptics;

  @override
  void initState() {
    super.initState();
    orient.Orientation.lockPortrait();
    _haptics = ProfileStore.instance.profile.hapticsEnabled;
  }

  Future<void> _toggleHaptics(bool v) async {
    setState(() => _haptics = v);
    await ProfileStore.instance.mutate((p) => p.hapticsEnabled = v);
    if (v) Haptics.parry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AegisPalette.voidNight,
      body: Stack(
        children: [
          const Positioned.fill(child: SkyBackdrop(accent: AegisPalette.underViolet)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AegisPalette.goldBright),
                      ),
                      Text('SETTINGS',
                          style: Glyph.title(size: 22, shadows: Glyph.goldGlow())),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _tile(
                    icon: Icons.vibration,
                    label: 'Haptics',
                    trailing: Switch(
                      value: _haptics,
                      activeThumbColor: AegisPalette.goldBright,
                      activeTrackColor: AegisPalette.goldDeep,
                      onChanged: _toggleHaptics,
                    ),
                  ),
                ),
                const Spacer(),
                const LegalRow(),
                const SizedBox(height: 10),
                Text('Olympus Aegis · v1.0',
                    style: Glyph.label(size: 11, color: AegisPalette.parchmentDim)),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({required IconData icon, required String label, required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AegisPalette.deepPurple.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AegisPalette.goldBright, size: 22),
          const SizedBox(width: 12),
          Text(label, style: Glyph.label(size: 15, color: AegisPalette.parchment)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
