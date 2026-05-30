import 'package:flutter/material.dart';

import '../../core/storage/profile_store.dart';
import '../../core/system/orientation.dart' as orient;
import '../../theme/aegis_palette.dart';
import '../../theme/glyph.dart';
import '../widgets/aegis_button.dart';
import '../widgets/sky_backdrop.dart';
import '../arena/arena_screen.dart';

class _Page {
  final String sigil;
  final String title;
  final String body;
  const _Page(this.sigil, this.title, this.body);
}

/// The Codex — a short, swipeable rulebook explaining the parry-defense loop
/// in very simple words. On first launch it leads straight into the tutorial.
class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key, this.firstRun = false});

  /// When true (first app launch) the final page starts the tutorial; when
  /// false (opened from the menu) it simply returns.
  final bool firstRun;

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = [
    _Page('🛡️', 'YOU ARE THE GOD',
        'You stand in the middle. Bad things fly at you from every side. Do not let them touch you!'),
    _Page('👉', 'SWIPE TO PUSH',
        'Swipe your finger toward a bad thing. Your shield pushes it away. Easy!'),
    _Page('✨', 'WAIT, THEN SWIPE',
        'Push right before it touches you to get a PERFECT. You earn lots more points!'),
    _Page('💚', 'GRAB THE GIFTS',
        'Green and gold balls are gifts. Do NOT push them. Let them come to you!'),
    _Page('⚡', 'BIG BLAST',
        'Every push fills your power bar. When it is full, tap it for a HUGE blast!'),
    _Page('⛰️', 'GIANT TITANS',
        'Sometimes a huge Titan comes. Push it again and again until it goes away!'),
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

  /// Finished reading: first launch → tutorial; otherwise return to caller.
  void _finish() {
    if (widget.firstRun) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ArenaScreen(tutorial: true)),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Closed early: first launch → skip straight to the Sanctuary.
  void _skip() {
    if (widget.firstRun) {
      Navigator.of(context).pushReplacementNamed('/sanctuary');
    } else {
      Navigator.of(context).pop();
    }
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
                    onPressed: _skip,
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
                    label: last ? (widget.firstRun ? 'TRY IT!' : 'ENTER ARENA') : 'NEXT',
                    sigil: last ? '⚔' : '→',
                    width: 320,
                    onTap: () {
                      if (last) {
                        _finish();
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
