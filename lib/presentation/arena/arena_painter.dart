import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/threats/threat.dart';
import '../../theme/aegis_palette.dart';
import 'arena_world.dart';

/// Renders the dynamic arena: guard ring, threats, parry flashes and the
/// transient ultimate effects. The deity art and HUD are layered as widgets
/// above/below this painter by [ArenaScreen].
class ArenaPainter extends CustomPainter {
  ArenaPainter(this.world) : super(repaint: world.frame);

  final ArenaWorld world;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(world.centre.x, world.centre.y);
    final acc = world.deity.accent;

    _drawGuardRing(canvas, c, acc);
    if (world.flameActive) _drawFlameRing(canvas, c);
    if (world.slowActive) _drawSlowVeil(canvas, size);

    // Threats below, flashes/floats above.
    for (final t in world.threats) {
      _drawThreat(canvas, c, t, acc);
    }
    for (final f in world.flashes) {
      _drawParryFlash(canvas, c, f, acc);
    }
    if (world.ultPulse > 0) _drawUltPulse(canvas, c, acc);
    for (final f in world.floats) {
      _drawFloat(canvas, f);
    }
  }

  // ── Guard ring (the timing guide where threats should be parried) ──────────
  void _drawGuardRing(Canvas canvas, Offset c, Color acc) {
    final t = (world.frame.value % 120) / 120.0;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = acc.withValues(alpha: 0.35 + pulse * 0.25);
    canvas.drawCircle(c, world.parryRadius, ring);

    // Inner faint core glow where the deity stands.
    final core = Paint()
      ..shader = RadialGradient(
        colors: [acc.withValues(alpha: 0.30), Colors.transparent],
      ).createShader(Rect.fromCircle(center: c, radius: world.coreRadius * 1.8));
    canvas.drawCircle(c, world.coreRadius * 1.8, core);

    // Tick marks around the ring for a temple-dial feel.
    final tick = Paint()
      ..color = AegisPalette.gold.withValues(alpha: 0.30)
      ..strokeWidth = 2;
    for (int i = 0; i < 12; i++) {
      final a = i / 12 * math.pi * 2;
      final p1 = c + Offset(math.cos(a), math.sin(a)) * (world.parryRadius - 6);
      final p2 = c + Offset(math.cos(a), math.sin(a)) * (world.parryRadius + 6);
      canvas.drawLine(p1, p2, tick);
    }
  }

  void _drawFlameRing(Canvas canvas, Offset c) {
    final t = world.frame.value / 6.0;
    for (int i = 0; i < 28; i++) {
      final a = i / 28 * math.pi * 2 + t * 0.04;
      final wob = math.sin(t * 0.3 + i) * 6;
      final r = world.parryRadius + 8 + wob;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      final flame = Paint()
        ..shader = RadialGradient(
          colors: [
            AegisPalette.goldBright.withValues(alpha: 0.9),
            AegisPalette.emberOrange.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: p, radius: 18));
      canvas.drawCircle(p, 18, flame);
    }
  }

  void _drawSlowVeil(Canvas canvas, Size size) {
    final veil = Paint()..color = AegisPalette.seaTeal.withValues(alpha: 0.06);
    canvas.drawRect(Offset.zero & size, veil);
  }

  // ── Threats ─────────────────────────────────────────────────────────────────
  void _drawThreat(Canvas canvas, Offset c, Threat t, Color acc) {
    final pos = t.positionFrom(world.centre);
    final p = Offset(pos.x, pos.y);

    double alpha = 1;
    double scale = 1;
    if (t.phase == ThreatPhase.repelled) {
      alpha = (1 - t.exitT / 0.4).clamp(0, 1);
    } else if (t.phase == ThreatPhase.collected) {
      alpha = (1 - t.exitT / 0.4).clamp(0, 1);
      scale = 1 + t.exitT * 1.5;
    } else if (t.phase == ThreatPhase.expired) {
      alpha = (1 - t.exitT / 0.4).clamp(0, 1);
    }

    switch (t.kind) {
      case ThreatKind.boulder:
        _blob(canvas, p, t.drawRadius * scale, const Color(0xFF8A6A4A),
            const Color(0xFF4A3524), alpha);
        break;
      case ThreatKind.darkBolt:
        _dart(canvas, p, t.displayBearing, t.drawRadius * scale, alpha);
        break;
      case ThreatKind.shade:
        _shade(canvas, p, t.drawRadius * scale, alpha);
        break;
      case ThreatKind.titan:
        _titan(canvas, p, t, alpha);
        break;
      case ThreatKind.blessing:
        _orb(canvas, p, t.drawRadius * scale, AegisPalette.blessing, alpha);
        break;
      case ThreatKind.essenceMote:
        _orb(canvas, p, t.drawRadius * scale, AegisPalette.goldBright, alpha);
        break;
    }
  }

  void _blob(Canvas canvas, Offset p, double r, Color a, Color b, double alpha) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [a.withValues(alpha: alpha), b.withValues(alpha: alpha)],
      ).createShader(Rect.fromCircle(center: p, radius: r));
    // A faceted rock — irregular polygon.
    final path = Path();
    const n = 7;
    for (int i = 0; i <= n; i++) {
      final ang = i / n * math.pi * 2;
      final rr = r * (0.82 + 0.18 * math.sin(ang * 3 + p.dx));
      final pt = p + Offset(math.cos(ang), math.sin(ang)) * rr;
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withValues(alpha: 0.25 * alpha),
    );
  }

  void _dart(Canvas canvas, Offset p, double bearing, double r, double alpha) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(bearing);
    final glow = Paint()
      ..color = AegisPalette.menaceGlow.withValues(alpha: 0.5 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final body = Paint()..color = AegisPalette.menace.withValues(alpha: alpha);
    final path = Path()
      ..moveTo(r * 1.6, 0)
      ..lineTo(-r, r * 0.7)
      ..lineTo(-r * 0.4, 0)
      ..lineTo(-r, -r * 0.7)
      ..close();
    canvas.drawPath(path, glow);
    canvas.drawPath(path, body);
    canvas.restore();
  }

  void _shade(Canvas canvas, Offset p, double r, double alpha) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AegisPalette.underViolet.withValues(alpha: 0.85 * alpha),
          AegisPalette.deepPurple.withValues(alpha: 0.1 * alpha),
        ],
      ).createShader(Rect.fromCircle(center: p, radius: r * 1.2));
    canvas.drawCircle(p, r, paint);
    // Two glowing eyes.
    final eye = Paint()..color = AegisPalette.menaceGlow.withValues(alpha: alpha);
    canvas.drawCircle(p + Offset(-r * 0.3, -r * 0.1), r * 0.12, eye);
    canvas.drawCircle(p + Offset(r * 0.3, -r * 0.1), r * 0.12, eye);
  }

  void _titan(Canvas canvas, Offset p, Threat t, double alpha) {
    final r = t.drawRadius;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6B5A8A).withValues(alpha: alpha),
          const Color(0xFF2A2140).withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromCircle(center: p, radius: r));
    canvas.drawCircle(p, r, paint);
    canvas.drawCircle(
      p,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AegisPalette.gold.withValues(alpha: 0.6 * alpha),
    );
    // HP pips.
    final pip = Paint()..color = AegisPalette.menaceGlow.withValues(alpha: alpha);
    for (int i = 0; i < t.hp; i++) {
      canvas.drawCircle(p + Offset((i - (t.hp - 1) / 2) * 12, -r - 12), 4, pip);
    }
  }

  void _orb(Canvas canvas, Offset p, double r, Color color, double alpha) {
    final glow = Paint()
      ..color = color.withValues(alpha: 0.5 * alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(p, r * 1.4, glow);
    final body = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: alpha), color.withValues(alpha: alpha)],
      ).createShader(Rect.fromCircle(center: p, radius: r));
    canvas.drawCircle(p, r, body);
  }

  // ── Parry flash arc ──────────────────────────────────────────────────────────
  void _drawParryFlash(Canvas canvas, Offset c, ParryFlash f, Color acc) {
    final progress = (f.t / 0.32).clamp(0.0, 1.0);
    final alpha = (1 - progress);
    final color = f.perfect ? AegisPalette.goldBright : acc;
    final sweep = (f.perfect ? 1.0 : 0.7);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (f.perfect ? 9 : 6) * (1 - progress * 0.4)
      ..color = color.withValues(alpha: alpha);
    final rect = Rect.fromCircle(center: c, radius: world.parryRadius);
    canvas.drawArc(rect, f.angle - sweep / 2, sweep, false, paint);
  }

  void _drawUltPulse(Canvas canvas, Offset c, Color acc) {
    final r = world.parryRadius + (1 - world.ultPulse) * world.arenaRadius * 0.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * world.ultPulse
      ..color = acc.withValues(alpha: 0.6 * world.ultPulse);
    canvas.drawCircle(c, r, paint);
  }

  void _drawFloat(Canvas canvas, FloatText f) {
    final progress = (f.t / 0.9).clamp(0.0, 1.0);
    final dy = -progress * 38;
    final alpha = (1 - progress);
    final tp = TextPainter(
      text: TextSpan(
        text: f.text,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: f.color.withValues(alpha: alpha),
          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5 * alpha), blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(f.origin.dx - tp.width / 2, f.origin.dy + dy));
  }

  @override
  bool shouldRepaint(covariant ArenaPainter oldDelegate) => true;
}
