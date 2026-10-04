import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import 'returns_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int tab) onGo;
  const HomeScreen({super.key, required this.onGo});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeSnapshot? _snap;
  String? _error;
  bool _loading = true;

  MfUser? get _user => repo.user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await repo.homeSnapshot();
      if (!mounted) return;
      setState(() {
        _snap = snap;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
        return;
      }
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل بيانات الصيدلية';
        _loading = false;
      });
    }
  }

  String get _hello {
    final h = DateTime.now().hour;
    return h < 12 ? 'صباح الخير،' : 'مساء الخير،';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final user = _user;
    final pharmacy = user?.pharmacyName.isNotEmpty == true ? user!.pharmacyName : 'مدفليت';
    final branch = user?.branch ?? '';
    final pending = _snap?.pendingReturns ?? 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Row(children: [
          MfIcon('pin', size: 18, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(text: pharmacy, style: sans(13, w: FontWeight.w700, c: p.mute)),
              if (branch.isNotEmpty) TextSpan(text: ' · $branch', style: sans(13, c: p.mute)),
            ])),
          ),
          MfIconButton(
            onTap: _load,
            child: MfIcon('bell', size: 21, color: p.ink),
          ),
        ]),
        const SizedBox(height: 22),
        Text(_hello, style: kufi(34, c: p.ink, h: 1.25)),
        Text(user?.firstName ?? 'أهلاً', style: kufi(34, c: p.accent, h: 1.25)),
        const SizedBox(height: 22),
        _panel(context),
        if (_error != null) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _load,
            child: Text(_error!, style: sans(13, c: p.red)),
          ),
        ],
        const SizedBox(height: 22),
        Text('الأقسام', style: sans(12, c: p.mute)),
        const SizedBox(height: 4),
        _row(context, 'box', 'المخزن', 'تصفح الأدوية وتتبع الصلاحية', () => widget.onGo(1)),
        _row(context, 'list', 'الجرد المخزني', 'باركود سريع + فرق مالي', () => widget.onGo(3)),
        _row(context, 'ret', 'مردود الشراء', 'طلبات الإرجاع للمجهز', () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReturnsScreen()));
        }, badge: pending > 0 ? '$pending' : null),
        _row(context, 'set', 'الإعدادات', 'الحساب والتطبيق', () => widget.onGo(4), last: true),
      ],
    );
  }

  Widget _panel(BuildContext context) {
    final p = context.mf;
    final snap = _snap;
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
        if (_loading && snap == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: CircularProgressIndicator(color: Colors.white),
          )
        else
          Row(children: [
            stat(fmtNum(snap?.skuCount ?? 0), 'صنف بالمخزن', Colors.white),
            stat(fmtNum(snap?.soon ?? 0), 'تنتهي قريباً', const Color(0xFFF6D77C)),
            stat(fmtNum(snap?.expired ?? 0), 'منتهية', const Color(0xFFFFB4A3)),
          ]),
        const SizedBox(height: 18),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => widget.onGo(2),
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
