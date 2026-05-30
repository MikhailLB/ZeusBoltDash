import 'package:flutter/material.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/aegis_button.dart';
import '../widgets/sky_backdrop.dart';

class _Page {
  final String sigil;
  final String title;
  final String body;
  const _Page(this.sigil, this.title, this.body);
}

/// The Codex — a short, swipeable rulebook explaining the parry-defense loop.
class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _Page('🛡️', 'HOLD THE CORE',
        'You stand at the heart of the arena. Threats converge from every gate. Let none reach you.'),
    _Page('👉', 'SWIPE TO PARRY',
        'Flick toward an incoming threat to raise your aegis in that direction and cast it back.'),
    _Page('✨', 'PERFECT TIMING',
        'Parry at the last moment for a PERFECT — double score and a far greater surge of Wrath.'),
    _Page('💚', 'TAKE THE BLESSING',
        'Green blessings and golden motes are gifts. Do NOT parry them — let them reach the core.'),
    _Page('⚡', 'UNLEASH WRATH',
        'Parries fill your Wrath meter. When it is full, tap it to unleash your deity\'s ultimate.'),
    _Page('⛰️', 'BREAK THE TITANS',
        'Every fifth wave the Titans march. They shrug off single hits — parry them again and again.'),
  ];

  @override
  void initState() {
    super.initState();
    orient.Orientation.lockPortrait();
    ProfileStore.instance.mutate((p) => p.seenCodex = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      backgroundColor: AegisPalette.voidNight,
      body: Stack(
        children: [
          const Positioned.fill(child: SkyBackdrop(accent: AegisPalette.skyBlue)),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AegisPalette.goldBright),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _pageView(_pages[i]),
                  ),
                ),
                _dots(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AegisButton(
                    label: last ? 'ENTER ARENA' : 'NEXT',
                    sigil: last ? '⚔' : '→',
                    width: 320,
                    onTap: () {
                      if (last) {
                        Navigator.of(context).pop();
                      } else {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageView(_Page p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AegisPalette.gold.withValues(alpha: 0.3),
                Colors.transparent,
              ]),
              border: Border.all(color: AegisPalette.gold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Center(child: Text(p.sigil, style: const TextStyle(fontSize: 56))),
          ),
          const SizedBox(height: 28),
          Text(p.title,
              textAlign: TextAlign.center,
              style: Glyph.title(size: 24, shadows: Glyph.goldGlow())),
          const SizedBox(height: 16),
          Text(p.body,
              textAlign: TextAlign.center,
              style: Glyph.label(size: 15, color: AegisPalette.parchment)),
        ],
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < _pages.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _index
                  ? AegisPalette.goldBright
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
