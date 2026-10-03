import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'tokens.dart';

String _hex(Color c) => '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Custom duotone icon set: tinted body + stroked outline + one gold detail.
String _inner(String name, String c, String g) {
  final tint = 'fill="$c" fill-opacity=".16" stroke="none"';
  switch (name) {
    case 'box':
      return '<rect x="3" y="8" width="18" height="13" rx="3" $tint/>'
          '<path d="M4.5 8L6.4 4.2A1.5 1.5 0 017.7 3.4h8.6a1.5 1.5 0 011.3.8L19.5 8"/>'
          '<rect x="3" y="8" width="18" height="13" rx="3"/>'
          '<path d="M12 12v5M9.5 14.5h5" stroke="$g"/>';
    case 'list':
      return '<rect x="5" y="4" width="14" height="17" rx="3" $tint/>'
          '<rect x="5" y="4" width="14" height="17" rx="3"/>'
          '<rect x="9" y="2.2" width="6" height="3.6" rx="1.4"/>'
          '<path d="M9 11h6M9 14.5h3"/><path d="M9.2 18l1.6 1.4 3-3" stroke="$g"/>';
    case 'ret':
      return '<path d="M4 11h10.5a5 5 0 010 10H11"/><path d="M9 6l-5 5 5 5" stroke="$g"/>';
    case 'set':
      return '<path d="M4 7h8.5M19.5 7H20M4 17h.5M11.5 17H20"/>'
          '<circle cx="16" cy="7" r="3" $tint/><circle cx="16" cy="7" r="3"/>'
          '<circle cx="8" cy="17" r="3" $tint/><circle cx="8" cy="17" r="3" stroke="$g"/>';
    case 'scan':
      return '<path d="M4 8V6.5A2.5 2.5 0 016.5 4H8M16 4h1.5A2.5 2.5 0 0120 6.5V8M20 16v1.5a2.5 2.5 0 01-2.5 2.5H16M8 20H6.5A2.5 2.5 0 014 17.5V16"/>'
          '<path d="M7.5 12h9" stroke="$g"/>';
    case 'bell':
      return '<path d="M6 9a6 6 0 0112 0c0 6 2.5 7.5 2.5 7.5h-17S6 15 6 9z" $tint/>'
          '<path d="M6 9a6 6 0 0112 0c0 6 2.5 7.5 2.5 7.5h-17S6 15 6 9z"/>'
          '<path d="M10.2 20a2 2 0 003.6 0" stroke="$g"/>';
    case 'home':
      return '<path d="M4.5 10.5L12 4l7.5 6.5V19a1.5 1.5 0 01-1.5 1.5H6A1.5 1.5 0 014.5 19z" $tint/>'
          '<path d="M4.5 10.5L12 4l7.5 6.5V19a1.5 1.5 0 01-1.5 1.5H6A1.5 1.5 0 014.5 19z"/>'
          '<path d="M10 20.5v-5h4v5" stroke="$g"/>';
    case 'pin':
      return '<path d="M12 21.5s6.5-5.6 6.5-11a6.5 6.5 0 10-13 0c0 5.4 6.5 11 6.5 11z" $tint/>'
          '<path d="M12 21.5s6.5-5.6 6.5-11a6.5 6.5 0 10-13 0c0 5.4 6.5 11 6.5 11z"/>'
          '<circle cx="12" cy="10.5" r="2.3" stroke="$g"/>';
    case 'search':
      return '<circle cx="11" cy="11" r="6.5" $tint/><circle cx="11" cy="11" r="6.5"/>'
          '<path d="M16 16l4 4" stroke="$g"/>';
    case 'plus':
      return '<path d="M12 5v14M5 12h14"/>';
    case 'minus':
      return '<path d="M5 12h14"/>';
    case 'check':
      return '<path d="M5 12.5l4.5 4.5L19 7.5"/>';
    case 'user':
      return '<circle cx="12" cy="8" r="4" $tint/><circle cx="12" cy="8" r="4"/>'
          '<path d="M4.5 21c.8-4 3.7-6 7.5-6s6.7 2 7.5 6" stroke="$g"/>';
    case 'out':
      return '<path d="M10 4H6.5A2.5 2.5 0 004 6.5v11A2.5 2.5 0 006.5 20H10M15 8l4 4-4 4M19 12H9"/>';
    case 'moon':
      return '<path d="M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z" $tint/>'
          '<path d="M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z"/>';
    case 'fp':
      return '<path d="M6 11a6 6 0 0112 0v2M12 11v6M9 14c0 3 1 5 2 6M15 14c0 2-.5 4-1.5 6M3 12a9 9 0 0118 0"/>';
    case 'truck':
      return '<path d="M3 6h11v10H3zM14 9h4l3 3v4h-7" $tint/><path d="M3 6h11v10H3zM14 9h4l3 3v4h-7"/>'
          '<circle cx="7.5" cy="17.5" r="1.8" stroke="$g"/><circle cx="17" cy="17.5" r="1.8" stroke="$g"/>';
    case 'eye':
      return '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>';
    case 'lock':
      return '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 018 0v3"/>';
    case 'chev': // points down
      return '<path d="M6 9l6 6 6-6"/>';
  }
  return '';
}

/// Duotone icon. [color] = main stroke/tint, [gold] = accent detail.
class MfIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  final Color? gold;
  final double strokeWidth;
  const MfIcon(this.name, {super.key, this.size = 22, this.color, this.gold, this.strokeWidth = 1.7});

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final c = _hex(color ?? p.ink);
    final g = _hex(gold ?? p.gold);
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="$c" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">'
        '${_inner(name, c, g)}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// Brand mark: white "M" + gold plus badge on an emerald gradient squircle.
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
        '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">'
        '<stop offset="0" stop-color="${_hex(p.l1)}"/><stop offset=".55" stop-color="${_hex(p.l2)}"/>'
        '<stop offset="1" stop-color="${_hex(p.l3)}"/></linearGradient></defs>'
        '<rect width="64" height="64" rx="16" fill="url(#g)"/>'
        '<path d="M13 46V23l14.5 14L42 23v23" fill="none" stroke="#ffffff" stroke-width="6.2" '
        'stroke-linecap="round" stroke-linejoin="round"/>'
        '<circle cx="47.5" cy="16.5" r="9" fill="#E2B547"/>'
        '<path d="M47.5 12v9M43 16.5h9" stroke="#3A2A04" stroke-width="2.6" stroke-linecap="round"/></svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}

/// "medfleet" wordmark.
class Wordmark extends StatelessWidget {
  final double size;
  const Wordmark({super.key, this.size = 26});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(TextSpan(children: [
        TextSpan(text: 'med', style: mono(size, c: p.ink).copyWith(letterSpacing: -1)),
        TextSpan(
            text: 'fleet',
            style: mono(size, w: FontWeight.w500, c: p.accent).copyWith(letterSpacing: -1)),
      ])),
    );
  }
}
