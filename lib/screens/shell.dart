import 'package:flutter/material.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import 'count_screen.dart';
import 'home_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import 'stock_screen.dart';

/// Tabs: 0 home, 1 stock, 2 scan (center FAB), 3 count, 4 settings.
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;

  void go(int i) => setState(() => _i = i);

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final pages = <Widget>[
      HomeScreen(onGo: go),
      StockScreen(onBack: () => go(0)),
      _i == 2 ? ScanScreen(onBack: () => go(0)) : const SizedBox.shrink(), // built only while visible (camera/timer)
      CountScreen(onBack: () => go(0)),
      SettingsScreen(onBack: () => go(0)),
    ];
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: IndexedStack(index: _i, children: pages),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 398),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: p.surface.withOpacity(.96),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: p.line),
                  boxShadow: [BoxShadow(color: p.l3.withOpacity(.25), blurRadius: 30, offset: const Offset(0, 16), spreadRadius: -18)],
                ),
                child: Row(children: [
                  _item(0, 'home', 'الرئيسية'),
                  _item(1, 'box', 'المخزن'),
                  _fab(),
                  _item(3, 'list', 'الجرد'),
                  _item(4, 'set', 'الإعدادات'),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int i, String icon, String label) {
    final p = context.mf;
    final on = _i == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => go(i),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              color: on ? p.greenS : Colors.transparent, borderRadius: BorderRadius.circular(99)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            MfIcon(icon, size: 22, color: on ? p.accent : p.mute),
            const SizedBox(height: 2),
            Text(label,
                style: sans(11, w: on ? FontWeight.w700 : FontWeight.w500, c: on ? p.accent : p.mute)),
          ]),
        ),
      ),
    );
  }

  Widget _fab() {
    final p = context.mf;
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -16),
          child: GestureDetector(
            onTap: () => go(2),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [p.l1, p.l3]),
                boxShadow: [BoxShadow(color: p.l3.withOpacity(.6), blurRadius: 20, offset: const Offset(0, 12), spreadRadius: -8)],
              ),
              child: Center(child: MfIcon('scan', size: 27, color: Colors.white, gold: p.goldOnTile, strokeWidth: 1.9)),
            ),
          ),
        ),
      ),
    );
  }
}
