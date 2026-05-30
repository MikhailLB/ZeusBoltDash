import 'package:flutter/material.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../core/audio/haptics.dart';
import '../../domain/deities/deity.dart';
import '../../domain/deities/deity_catalog.dart';
import '../../domain/progression/relics.dart';
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/aegis_chip.dart';
import '../widgets/sky_backdrop.dart';

/// The Pantheon: choose/unlock a deity and spend essence on permanent Relics.
class PantheonScreen extends StatefulWidget {
  const PantheonScreen({super.key});

  @override
  State<PantheonScreen> createState() => _PantheonScreenState();
}

class _PantheonScreenState extends State<PantheonScreen> {
  @override
  void initState() {
    super.initState();
    orient.Orientation.lockPortrait();
  }

  ProfileStore get _store => ProfileStore.instance;

  Future<void> _selectDeity(Deity d) async {
    final p = _store.profile;
    if (p.ownsDeity(d.id)) {
      await _store.mutate((p) => p.deity = d.id);
      Haptics.parry();
      setState(() {});
      return;
    }
    if (p.essence >= d.price) {
      await _store.mutate((p) {
        p.essence -= d.price;
        p.unlockedDeities.add(d.id);
        p.deity = d.id;
        if (p.unlockedDeities.length >= DeityCatalog.all.length) {
          p.earnTrial('pantheon');
        }
      });
      Haptics.surge();
      setState(() {});
    } else {
      _toast('Not enough essence');
    }
  }

  Future<void> _upgrade(Relic relic) async {
    final p = _store.profile;
    final cost = relic.nextCost(p);
    if (cost == null) return;
    if (p.essence < cost) {
      _toast('Not enough essence');
      return;
    }
    await _store.mutate((p) {
      p.essence -= cost;
      relic.setLevel(p, relic.levelOf(p) + 1);
    });
    Haptics.perfect();
    setState(() {});
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: Glyph.label(color: Colors.white)),
      backgroundColor: AegisPalette.menace,
      duration: const Duration(milliseconds: 1100),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = _store.profile;
    final accent = DeityCatalog.byId(p.deity).accent;
    return Scaffold(
      backgroundColor: AegisPalette.voidNight,
      body: Stack(
        children: [
          Positioned.fill(child: SkyBackdrop(accent: accent)),
          SafeArea(
            child: Column(
              children: [
                _header(p.essence),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
                    children: [
                      _sectionTitle('CHOOSE YOUR DEITY'),
                      const SizedBox(height: 10),
                      ...DeityCatalog.all.map(_deityCard),
                      const SizedBox(height: 22),
                      _sectionTitle('RELICS OF OLYMPUS'),
                      const SizedBox(height: 10),
                      ...RelicCatalog.all.map(_relicCard),
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

  Widget _header(int essence) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AegisPalette.goldBright),
          ),
          Text('PANTHEON', style: Glyph.title(size: 22, shadows: Glyph.goldGlow())),
          const Spacer(),
          AegisChip(icon: Icons.diamond, label: '$essence', iconColor: AegisPalette.seaTeal),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: Glyph.label(size: 13, color: AegisPalette.parchmentDim, tracking: 3));

  Widget _deityCard(Deity d) {
    final p = _store.profile;
    final owned = p.ownsDeity(d.id);
    final active = p.deity == d.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectDeity(d),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                d.accent.withValues(alpha: active ? 0.34 : 0.16),
                AegisPalette.deepPurple.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? d.accent : AegisPalette.gold.withValues(alpha: 0.4),
              width: active ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 86,
                height: 104,
                child: Image.asset(d.characterAsset, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: Glyph.title(size: 18, color: Colors.white, tracking: 2)),
                      Text(d.epithet,
                          style: Glyph.label(size: 11, color: AegisPalette.parchmentDim)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.flash_on, size: 13, color: d.accent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(d.ultimateName,
                                style: Glyph.label(size: 11, color: d.accent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _deityTag(owned, active, d.price),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deityTag(bool owned, bool active, int price) {
    if (active) {
      return Text('ACTIVE', style: Glyph.label(size: 12, color: AegisPalette.goldBright));
    }
    if (owned) {
      return Text('SELECT', style: Glyph.label(size: 12, color: AegisPalette.parchment));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline, color: AegisPalette.parchmentDim, size: 16),
        const SizedBox(height: 2),
        Text('$price 💎', style: Glyph.readout(size: 13, color: AegisPalette.seaTeal)),
      ],
    );
  }

  Widget _relicCard(Relic relic) {
    final p = _store.profile;
    final level = relic.levelOf(p);
    final cost = relic.nextCost(p);
    final maxed = cost == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AegisPalette.deepPurple.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Text(relic.sigil, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(relic.name, style: Glyph.title(size: 15, color: Colors.white, tracking: 1.5)),
                  Text(relic.effectAt(level),
                      style: Glyph.label(size: 11, color: AegisPalette.parchmentDim)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (int i = 0; i < relic.maxLevel; i++)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 16,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i < level
                                ? AegisPalette.goldBright
                                : Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: maxed ? null : () => _upgrade(relic),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  gradient: maxed
                      ? null
                      : const LinearGradient(
                          colors: [AegisPalette.goldDeep, AegisPalette.gold]),
                  color: maxed ? Colors.white.withValues(alpha: 0.08) : null,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.6)),
                ),
                child: Text(
                  maxed ? 'MAX' : '$cost 💎',
                  style: Glyph.readout(size: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
