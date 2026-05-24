import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _vibration;
  late int _highScore;

  @override
  void initState() {
    super.initState();
    _vibration = StorageService.instance.getVibration();
    _highScore = StorageService.instance.getHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A40), Color(0xFF0D0530)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4A017), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A017).withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SETTINGS',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFD700),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              color: const Color(0xFFD4A017).withOpacity(0.5),
            ),
            const SizedBox(height: 20),

            // High Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1A50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6A5A90)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BEST SCORE',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFCCBBFF),
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Color(0xFFD4A017), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '$_highScore',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Vibration toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1A50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6A5A90)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vibration,
                          color: Color(0xFFCCBBFF), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'VIBRATION',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFCCBBFF),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _vibration,
                    onChanged: (val) async {
                      setState(() => _vibration = val);
                      await StorageService.instance.setVibration(val);
                    },
                    activeThumbColor: const Color(0xFFD4A017),
                    activeTrackColor: const Color(0xFF8B6914),
                    inactiveThumbColor: const Color(0xFF6A5A90),
                    inactiveTrackColor: const Color(0xFF2A1A50),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B6914), Color(0xFFD4A017)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFFD4A017)),
                ),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
