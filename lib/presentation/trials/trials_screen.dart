import 'package:flutter/material.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../domain/progression/trials.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/sky_backdrop.dart';

/// "Trials of the Gods" — achievements and lifetime statistics.
class TrialsScreen extends StatefulWidget {
  const TrialsScreen({super.key});

  @override
  State<TrialsScreen> createState() => _TrialsScreenState();
}

class _TrialsScreenState extends State<TrialsScreen> {
  @override
  void initState() {
    super.initState();
    orient.Orientation.lockPortrait();
  }

  @override
  Widget build(BuildContext context) {
    final p = ProfileStore.instance.profile;
    final earned = p.earnedTrials.toSet();

    return Scaffold(
      backgroundColor: AegisPalette.voidNight,
      body: Stack(
        children: [
          const Positioned.fill(child: SkyBackdrop(accent: AegisPalette.emberOrange)),
          SafeArea(
            child: Column(
              children: [
                _header(earned.length),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                    children: [
                      _statsPanel(p),
                      const SizedBox(height: 18),
                      Text('TRIALS',
                          style: Glyph.label(
                              size: 13, color: AegisPalette.parchmentDim, tracking: 3)),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.55,
                        children: [
                          for (final t in TrialCatalog.all)
                            _trialCard(t, earned.contains(t.id)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AegisPalette.goldBright),
          ),
          Text('TRIALS', style: Glyph.title(size: 22, shadows: Glyph.goldGlow())),
          const Spacer(),
          Text('$count / ${TrialCatalog.all.length}',
              style: Glyph.readout(size: 16, color: AegisPalette.goldBright)),
        ],
      ),
    );
  }

  Widget _statsPanel(p) {
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Glyph.label(size: 12, color: AegisPalette.parchmentDim)),
              Text(value, style: Glyph.readout(size: 14, color: AegisPalette.parchment)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AegisPalette.deepPurple.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text('CHRONICLE',
              style: Glyph.label(size: 13, color: AegisPalette.goldBright, tracking: 3)),
          const SizedBox(height: 8),
          row('High score', '${p.highScore}'),
          row('Best wave', '${p.bestWave}'),
          row('Sieges fought', '${p.trialsRun}'),
          row('Threats repelled', '${p.threatsRepelled}'),
          row('Perfect parries', '${p.perfectParries}'),
          row('Best streak', '${p.bestParryStreak}'),
          row('Titans felled', '${p.titansFelled}'),
          row('Ultimates unleashed', '${p.ultimatesUnleashed}'),
        ],
      ),
    );
  }

  Widget _trialCard(Trial t, bool earned) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: earned
              ? [AegisPalette.goldDeep.withValues(alpha: 0.6), AegisPalette.deepPurple]
              : [AegisPalette.deepPurple.withValues(alpha: 0.5), AegisPalette.voidNight],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned ? AegisPalette.gold : Colors.white.withValues(alpha: 0.12),
          width: earned ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Opacity(
                opacity: earned ? 1 : 0.35,
                child: Text(t.sigil, style: const TextStyle(fontSize: 22)),
              ),
              const Spacer(),
              Icon(earned ? Icons.verified : Icons.lock_outline,
                  size: 16,
                  color: earned ? AegisPalette.goldBright : AegisPalette.parchmentDim),
            ],
          ),
          const Spacer(),
          Text(t.title,
              style: Glyph.title(
                  size: 13,
                  color: earned ? Colors.white : AegisPalette.parchmentDim,
                  tracking: 1)),
          const SizedBox(height: 3),
          Text(t.detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Glyph.label(size: 10, color: AegisPalette.parchmentDim)),
        ],
      ),
    );
  }
}
