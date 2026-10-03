import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/tokens.dart';
import 'login_screen.dart';

/// Animated entry: tile pops in -> the "M" draws itself -> gold plus badge pops
/// -> ripple rings -> wordmark + tagline fade up -> fades into [LoginScreen].
/// Duration 2.9s. Change [next] if you want to route somewhere else (e.g. auto-login).
class SplashScreen extends StatefulWidget {
  final WidgetBuilder? next;
  const SplashScreen({super.key, this.next});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2900));

  Animation<double> _iv(double a, double b, [Curve k = Curves.easeOut]) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: k));

  late final _tile = _iv(0, .30, Curves.easeOutBack);
  late final _draw = _iv(.22, .55, Curves.easeInOutCubic);
  late final _badge = _iv(.52, .72, Curves.elasticOut);
  late final _ring = _iv(.55, 1.0, Curves.easeOut);
  late final _word = _iv(.62, .85, Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (ctx, _, __) => widget.next?.call(ctx) ?? const LoginScreen(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const l2 = Color(0xFF0F7B5F), l3 = Color(0xFF0A4F3E);
    return Scaffold(
      backgroundColor: l3,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [l2, l3]),
            ),
            child: Stack(alignment: Alignment.center, children: [
              // ripple rings
              for (var i = 0; i < 3; i++)
                Opacity(
                  opacity: (1 - _ring.value) * .35 * (_ring.value > 0 ? 1 : 0),
                  child: Container(
                    width: 130 + 360 * math.max(0, _ring.value - i * .12),
                    height: 130 + 360 * math.max(0, _ring.value - i * .12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(.5), width: 1.2),
                    ),
                  ),
                ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Transform.scale(
                  scale: .55 + .45 * _tile.value,
                  child: Opacity(
                    opacity: _tile.value.clamp(0.0, 1.0),
                    child: CustomPaint(
                      size: const Size(132, 132),
                      painter: _LogoPainter(draw: _draw.value, badge: _badge.value),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Opacity(
                  opacity: _word.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 14 * (1 - _word.value)),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: 'med', style: mono(34, c: Colors.white).copyWith(letterSpacing: -1.5)),
                        TextSpan(
                            text: 'fleet',
                            style: mono(34, w: FontWeight.w500, c: const Color(0xFF9BE9CF)).copyWith(letterSpacing: -1.5)),
                      ])),
                    ),
                  ),
                ),
              ]),
            ]),
          );
        },
      ),
    );
  }
}

/// White squircle tile + self-drawing emerald "M" + gold plus badge.
class _LogoPainter extends CustomPainter {
  final double draw, badge;
  _LogoPainter({required this.draw, required this.badge});

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 64;
    Offset tx(double x, double y) => Offset(32 + .78 * (x - 34.5), 32 + .78 * (y - 27.5)) * k;

    // tile
    final tile = RRect.fromRectAndRadius(Rect.fromLTWH(6 * k, 6 * k, 52 * k, 52 * k), Radius.circular(14 * k));
    canvas.drawShadow(Path()..addRRect(tile), Colors.black, 18, true);
    canvas.drawRRect(tile, Paint()..color = Colors.white);

    // M (progressively drawn)
    final path = Path()
      ..moveTo(tx(13, 46).dx, tx(13, 46).dy)
      ..lineTo(tx(13, 23).dx, tx(13, 23).dy)
      ..lineTo(tx(27.5, 37).dx, tx(27.5, 37).dy)
      ..lineTo(tx(42, 23).dx, tx(42, 23).dy)
      ..lineTo(tx(42, 46).dx, tx(42, 46).dy);
    final paint = Paint()
      ..color = const Color(0xFF0A5A46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.2 * .78 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * draw.clamp(0.0, 1.0)), paint);
    }

    // badge
    if (badge > 0) {
      final c = tx(47.5, 16.5);
      final r = 9 * .78 * k * badge;
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFFE2B547));
      final plus = Paint()
        ..color = const Color(0xFF3A2A04)
        ..strokeWidth = 2.6 * .78 * k * badge
        ..strokeCap = StrokeCap.round;
      final a = 4.5 * .78 * k * badge;
      canvas.drawLine(c.translate(0, -a), c.translate(0, a), plus);
      canvas.drawLine(c.translate(-a, 0), c.translate(a, 0), plus);
    }
  }

  @override
  bool shouldRepaint(_LogoPainter o) => o.draw != draw || o.badge != badge;
}
