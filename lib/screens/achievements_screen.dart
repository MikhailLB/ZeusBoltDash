import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/orientation_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final List<String> _unlocked;
  late final _Stats _stats;

  @override
  void initState() {
    super.initState();
    OrientationService.lockPortrait();
    final data = StorageService.instance.loadPlayerData();
    _unlocked = List<String>.from(data.unlockedAchievements);
    _stats = _Stats(
      gamesPlayed: data.gamesPlayed,
      highScore: data.highScore,
      totalLightnings: data.totalLightningsCaught,
      bestCombo: data.bestCombo,
      surgesUsed: data.totalSurgesUsed,
      ambrosiaCollected: data.totalAmbrosiaCollected,
      stormsSurvived: data.totalStormsSurvived,
    );

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount =
        kAchievements.where((a) => _unlocked.contains(a.id)).length;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/game_assets/bg_02_asset.webp',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF0A0520)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000020),
                  Color(0xBB000018),
                  Color(0xCC000020),
                ],
              ),
            ),
          ),
          // Content
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, unlockedCount),
                  _buildStatsPanel(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildGrid()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4A017)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFFFFD700), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OLYMPIAN FEATS',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFD700),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '$count / ${kAchievements.length} unlocked',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFCCBBFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Progress circle
          _ProgressCircle(
            value: count / kAchievements.length,
            count: count,
            total: kAchievements.length,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4A017).withValues(alpha: 0.5)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          _statChip('🎮', 'Games', '${_stats.gamesPlayed}'),
          _statChip('⚡', 'Best Score', '${_stats.highScore}'),
          _statChip('🔥', 'Best Combo', '×${_stats.bestCombo}'),
          _statChip('🌩️', 'Lightnings', '${_stats.totalLightnings}'),
          _statChip('💥', 'Surges', '${_stats.surgesUsed}'),
          _statChip('🏺', 'Ambrosia', '${_stats.ambrosiaCollected}'),
          _statChip('⛈️', 'Storms', '${_stats.stormsSurvived}'),
        ],
      ),
    );
  }

  Widget _statChip(String emoji, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        Text(
          value,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFFD700),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: Colors.white60,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemCount: kAchievements.length,
      itemBuilder: (context, i) {
        final a = kAchievements[i];
        final unlocked = _unlocked.contains(a.id);
        return _AchievementCard(achievement: a, unlocked: unlocked);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: unlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A0A40), Color(0xFF2A1460)],
              )
            : LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFD4A017).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.12),
          width: unlocked ? 1.5 : 1,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Emoji / locked icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? const Color(0xFFD4A017).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: unlocked
                    ? const Color(0xFFD4A017).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Center(
              child: unlocked
                  ? Text(achievement.emoji,
                      style: const TextStyle(fontSize: 20))
                  : Icon(Icons.lock_outline,
                      color: Colors.white.withValues(alpha: 0.3), size: 18),
            ),
          ),
          const SizedBox(width: 10),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.cinzel(
                    color: unlocked
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  achievement.description,
                  style: GoogleFonts.cinzel(
                    color: unlocked
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.25),
                    fontSize: 9,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final double value;
  final int count;
  final int total;

  const _ProgressCircle({
    required this.value,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
          ),
          Text(
            '$count',
            style: GoogleFonts.cinzel(
              color: const Color(0xFFFFD700),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats {
  final int gamesPlayed;
  final int highScore;
  final int totalLightnings;
  final int bestCombo;
  final int surgesUsed;
  final int ambrosiaCollected;
  final int stormsSurvived;

  const _Stats({
    required this.gamesPlayed,
    required this.highScore,
    required this.totalLightnings,
    required this.bestCombo,
    required this.surgesUsed,
    required this.ambrosiaCollected,
    required this.stormsSurvived,
  });
}
