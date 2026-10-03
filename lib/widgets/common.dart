import 'package:flutter/material.dart';
import '../core/icons.dart';
import '../core/tokens.dart';

/// Gradient squircle holding a duotone icon (the premium brand icon tile).
class IconTile extends StatelessWidget {
  final String icon;
  final double size;
  const IconTile(this.icon, {super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .34),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [p.l1, p.l2, p.l3],
          stops: const [0, .55, 1],
        ),
        boxShadow: [BoxShadow(color: p.l3.withOpacity(.45), blurRadius: 14, offset: const Offset(0, 8), spreadRadius: -8)],
      ),
      child: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .34),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.center,
                colors: [Colors.white.withOpacity(.26), Colors.transparent],
              ),
            ),
          ),
        ),
        Center(child: MfIcon(icon, size: size * .52, color: Colors.white, gold: p.goldOnTile)),
      ]),
    );
  }
}

/// Square outlined icon button (back / bell).
class MfIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const MfIconButton({super.key, required this.child, this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14), side: BorderSide(color: p.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(width: 42, height: 42, child: Center(child: child)),
      ),
    );
  }
}

/// Top bar for sub-screens. RTL: back arrow points right.
class MfBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  const MfBar({super.key, required this.title, this.subtitle, this.onBack});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Row(children: [
      if (onBack != null) ...[
        MfIconButton(
          onTap: onBack,
          child: RotatedBox(quarterTurns: 3, child: MfIcon('chev', size: 20, color: p.ink)),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: kufi(20, c: p.ink)),
          if (subtitle != null) Text(subtitle!, style: sans(12, c: p.mute)),
        ]),
      ),
    ]);
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onTap;
  final bool loading;
  final bool ghost;
  const PrimaryButton(this.label,
      {super.key, this.icon, this.onTap, this.loading = false, this.ghost = false});

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final disabled = onTap == null && !loading;
    final plain = ghost || disabled;
    final fg = plain ? (disabled ? p.mute : p.ink) : Colors.white;
    return Opacity(
      opacity: loading ? .8 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: plain ? p.surface : null,
            border: plain ? Border.all(color: p.line, width: 1.5) : null,
            gradient: plain
                ? null
                : LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [p.l1, p.l3]),
            boxShadow: plain
                ? null
                : [BoxShadow(color: p.l3.withOpacity(.5), blurRadius: 20, offset: const Offset(0, 12), spreadRadius: -12)],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: loading ? null : onTap,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      if (icon != null) ...[
                        MfIcon(icon!, size: 20, color: fg, gold: plain ? p.gold : p.goldOnTile),
                        const SizedBox(width: 10),
                      ],
                      Text(label, style: kufi(15, c: fg)),
                    ]),
            ),
          ),
        ),
      ),
    );
  }
}

class MfChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool on;
  final VoidCallback onTap;
  const MfChip(this.label, {super.key, this.count, required this.on, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: on ? p.accent2 : p.surface,
        shape: StadiumBorder(side: BorderSide(color: on ? p.accent2 : p.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: sans(13, w: FontWeight.w500, c: on ? Colors.white : p.ink)),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text('$count', style: mono(11, c: on ? Colors.white70 : p.mute)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const Pill(this.text, {super.key, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: sans(11.5, w: FontWeight.w700, c: fg)),
      );
}

class MfSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const MfSearchField({super.key, required this.controller, required this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line, width: 1.5),
      ),
      child: Row(children: [
        MfIcon('search', size: 20, color: p.mute),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: sans(14, w: FontWeight.w500, c: p.ink),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: hint,
              hintStyle: sans(14, c: p.mute),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Small  - 0 +  stepper.
class Stepper3 extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const Stepper3({super.key, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    Widget btn(String icon, VoidCallback f) => Material(
          color: p.surface,
          borderRadius: BorderRadius.circular(11),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: f,
            child: SizedBox(width: 34, height: 34, child: Center(child: MfIcon(icon, size: 16, color: p.ink))),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn('minus', () => onChanged(value > 0 ? value - 1 : 0)),
        SizedBox(width: 38, child: Center(child: Text('$value', style: mono(16, c: p.ink)))),
        btn('plus', () => onChanged(value + 1)),
      ]),
    );
  }
}

void showMfToast(BuildContext context, String msg) {
  final p = context.mf;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(msg, style: sans(13, c: p.bg), textAlign: TextAlign.center),
      backgroundColor: p.ink,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 110),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(milliseconds: 1600),
    ));
}

Future<T?> showMfSheet<T>(BuildContext context, Widget Function(BuildContext) builder) {
  final p = context.mf;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (c) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(c).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Container(
                width: 42, height: 5,
                decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(9))),
          ),
          const SizedBox(height: 14),
          builder(c),
        ]),
      ),
    ),
  );
}

/// 2-column key/value tiles used in sheets.
class KvGrid extends StatelessWidget {
  final List<(String, String)> items;
  const KvGrid(this.items, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (k, v) in items)
          Container(
            width: (MediaQuery.of(context).size.width - 40 - 10) / 2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: p.bg, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k, style: sans(11.5, c: p.mute)),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(v, style: mono(14, c: p.ink))),
            ]),
          ),
      ],
    );
  }
}
