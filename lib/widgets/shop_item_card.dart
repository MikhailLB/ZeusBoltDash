import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopItemCard extends StatelessWidget {
  final Widget preview;
  final String name;
  final int price;
  final bool owned;
  final bool equipped;
  final bool canAfford;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  const ShopItemCard({
    super.key,
    required this.preview,
    required this.name,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.canAfford,
    required this.onBuy,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2A1A50),
            const Color(0xFF1A0A30),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: equipped
              ? const Color(0xFFD4A017)
              : const Color(0xFF6A5A90),
          width: equipped ? 2.5 : 1,
        ),
        boxShadow: [
          if (equipped)
            BoxShadow(
              color: const Color(0xFFD4A017).withOpacity(0.4),
              blurRadius: 12,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview area
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 130,
              color: const Color(0xFF120830),
              child: Center(child: preview),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(
                  name,
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                if (owned) ...[
                  if (equipped)
                    _tag('EQUIPPED', const Color(0xFFD4A017))
                  else
                    _buildEquipButton(),
                ] else ...[
                  _buildBuyButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEquipButton() {
    return GestureDetector(
      onTap: onEquip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A1A60), Color(0xFF3A2A80)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8A7AB0)),
        ),
        child: Text(
          'EQUIP',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFCCBBFF),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBuyButton() {
    return GestureDetector(
      onTap: canAfford ? onBuy : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canAfford
                ? [const Color(0xFF8B6914), const Color(0xFFD4A017)]
                : [const Color(0xFF3A3A3A), const Color(0xFF2A2A2A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: canAfford
                ? const Color(0xFFD4A017)
                : const Color(0xFF555555),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 14),
            const SizedBox(width: 4),
            Text(
              '$price',
              style: GoogleFonts.cinzel(
                color: canAfford ? const Color(0xFFFFD700) : const Color(0xFF777777),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
