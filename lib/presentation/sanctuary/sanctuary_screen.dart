import 'package:flutter/material.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../domain/deities/deity_catalog.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/aegis_button.dart';
import '../widgets/aegis_chip.dart';
import '../widgets/sky_backdrop.dart';
import 'legal.dart';

/// The home hub ("Sanctuary"): choose to fight, visit the Pantheon, review
/// Trials, read the Codex or adjust settings.
class SanctuaryScreen extends StatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  State<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends State<SanctuaryScreen> {
  int _essence = 0;
  int _bestWave = 0;
  int _highScore = 0;
  int _blessing = 0;

  @override
  void initState() {
    super.initState();
    orient.Orientation.lockPortrait();
    _load();
  }

  Future<void> _load() async {
    final blessing = await ProfileStore.instance.claimBlessing();
    if (!mounted) return;
    final p = ProfileStore.instance.profile;
    setState(() {
      _essence = p.essence;
      _bestWave = p.bestWave;
      _highScore = p.highScore;
      _blessing = blessing;
    });
  }

  Future<void> _go(String route) async {
    await Navigator.of(context).pushNamed(route);
    if (mounted) _load(); // refresh currency/records on return
  }

  @override
  Widget build(BuildContext context) {
    final deity = DeityCatalog.byId(ProfileStore.instance.profile.deity);
    return Scaffold(
      backgroundColor: AegisPalette.voidNight,
      body: Stack(
        children: [
          Positioned.fill(child: SkyBackdrop(accent: deity.accent)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, c) {
                final compact = c.maxHeight < 680;
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    _topBar(),
                    if (_blessing > 0) ...[
                      const SizedBox(height: 8),
                      _blessingBanner(),
                    ],
                    Expanded(child: Center(child: _title(c.maxWidth, deity.accent, compact))),
                    _buttons(deity.accent),
                    SizedBox(height: compact ? 12 : 18),
                    const LegalRow(),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AegisChip(icon: Icons.diamond, label: '$_essence', iconColor: AegisPalette.seaTeal),
          const Spacer(),
          _icon(Icons.menu_book_rounded, () => _go('/codex')),
          const SizedBox(width: 10),
          _icon(Icons.settings_rounded, () => _go('/settings')),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.55)),
        ),
        child: Icon(icon, color: AegisPalette.goldBright, size: 20),
      ),
    );
  }

  Widget _blessingBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2200), Color(0xFF5A4500), Color(0xFF2A2200)],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AegisPalette.gold),
        ),
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('DAILY BLESSING — the gods favour you',
                  style: Glyph.label(size: 11, color: AegisPalette.goldBright)),
            ),
            Text('+$_blessing 💎',
                style: Glyph.readout(size: 14, color: AegisPalette.goldBright)),
          ],
        ),
      ),
    );
  }

  Widget _title(double w, Color accent, bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/Game_Name.webp',
          width: w * 0.8,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Text('OLYMPUS AEGIS',
              style: Glyph.title(size: 30, shadows: Glyph.goldGlow())),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text('AEGIS OF OLYMPUS',
            style: Glyph.label(size: 12, color: AegisPalette.parchmentDim, tracking: 4)),
        if (_highScore > 0 || _bestWave > 0) ...[
          SizedBox(height: compact ? 10 : 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AegisChip(icon: Icons.emoji_events, label: 'BEST $_highScore'),
              const SizedBox(width: 10),
              AegisChip(
                  icon: Icons.shield_moon_outlined,
                  label: 'WAVE $_bestWave',
                  iconColor: accent),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buttons(Color accent) {
    return Column(
      children: [
        AegisButton(label: 'ENTER ARENA', sigil: '⚔', accent: accent, onTap: () => _go('/arena')),
        const SizedBox(height: 12),
        AegisButton(
            label: 'PANTHEON',
            sigil: '🏛',
            accent: AegisPalette.gold,
            onTap: () => _go('/pantheon')),
        const SizedBox(height: 12),
        AegisButton(
            label: 'TRIALS',
            sigil: '👑',
            accent: AegisPalette.emberOrange,
            onTap: () => _go('/trials')),
      ],
    );
  }
}
