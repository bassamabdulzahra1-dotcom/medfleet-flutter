import 'package:flutter/material.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../widgets/common.dart';
import 'returns_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int tab) onGo;
  const HomeScreen({super.key, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        // top: branch + bell
        Row(children: [
          MfIcon('pin', size: 18, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => showMfToast(context, 'تبديل الفرع · قيد التصميم'),
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'صيدلية الأمل', style: sans(13, w: FontWeight.w700, c: p.mute)),
                TextSpan(text: ' · الكرادة', style: sans(13, c: p.mute)),
              ])),
            ),
          ),
          MfIconButton(
            onTap: () => showMfToast(context, 'لا توجد إشعارات جديدة'),
            child: Stack(clipBehavior: Clip.none, children: [
              MfIcon('bell', size: 21, color: p.ink),
              PositionedDirectional(
                top: 0, end: 1,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: p.red, shape: BoxShape.circle, border: Border.all(color: p.surface, width: 1.5)),
                ),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 22),
        Text('صباح الخير،', style: kufi(34, c: p.ink, h: 1.25)),
        Text('بكر عامر', style: kufi(34, c: p.accent, h: 1.25)),
        const SizedBox(height: 22),
        _panel(context),
        const SizedBox(height: 22),
        Text('الأقسام', style: sans(12, c: p.mute)),
        const SizedBox(height: 4),
        _row(context, 'box', 'المخزن', 'تصفح الأدوية وتتبع الصلاحية', () => onGo(1)),
        _row(context, 'list', 'الجرد المخزني', 'باركود سريع + فرق مالي', () => onGo(3)),
        _row(context, 'ret', 'مردود الشراء', 'طلبات الإرجاع للمجهز', () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReturnsScreen()));
        }, badge: '3'),
        _row(context, 'set', 'الإعدادات', 'الحساب والتطبيق', () => onGo(4), last: true),
        const SizedBox(height: 20),
        Center(child: Text('الأسماء والأرقام أمثلة للمعاينة فقط', style: sans(11.5, c: p.mute))),
      ],
    );
  }

  Widget _panel(BuildContext context) {
    final p = context.mf;
    Widget stat(String n, String l, Color c) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(n, style: mono(26, c: c)),
            Text(l, style: sans(11.5, c: Colors.white.withOpacity(.8))),
          ]),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(color: p.panel, borderRadius: BorderRadius.circular(30)),
      child: Column(children: [
        Row(children: [
          stat('1,284', 'صنف بالمخزن', Colors.white),
          stat('37', 'تنتهي قريباً', const Color(0xFFF6D77C)),
          stat('4', 'منتهية', const Color(0xFFFFB4A3)),
        ]),
        const SizedBox(height: 18),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onGo(2),
            child: SizedBox(
              height: 54,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const MfIcon('scan', size: 22, color: Color(0xFF0A4F3E), gold: Color(0xFFC98F14)),
                const SizedBox(width: 10),
                Text('امسح فاتورة شراء', style: kufi(15, c: const Color(0xFF0A4F3E))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _row(BuildContext context, String icon, String title, String sub, VoidCallback onTap,
      {String? badge, bool last = false}) {
    final p = context.mf;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
        decoration: BoxDecoration(
            border: last ? null : Border(bottom: BorderSide(color: p.line))),
        child: Row(children: [
          IconTile(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: kufi(16, c: p.ink)),
              Text(sub, style: sans(12.5, c: p.mute)),
            ]),
          ),
          if (badge != null) ...[
            Pill(badge, bg: p.goldS, fg: p.gold),
            const SizedBox(width: 8),
          ],
          RotatedBox(quarterTurns: 1, child: MfIcon('chev', size: 18, color: p.mute)),
        ]),
      ),
    );
  }
}
