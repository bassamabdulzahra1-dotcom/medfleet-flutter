import 'package:flutter/material.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/repository.dart';
import '../main.dart' show themeMode;
import '../widgets/common.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SettingsScreen({super.key, required this.onBack});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notif = true;
  bool _leaving = false;

  Future<void> _logout() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    await repo.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final user = repo.user;
    final pharmacy = user?.pharmacyName.isNotEmpty == true ? user!.pharmacyName : 'مدفليت';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        MfBar(title: 'الإعدادات', onBack: widget.onBack),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: p.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: p.line)),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [p.l1, p.l3]),
              ),
              alignment: Alignment.center,
              child: Text(user?.initial ?? 'م', style: kufi(22, c: Colors.white)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? 'مستخدم مدفليت', style: kufi(17, c: p.ink)),
                Text(user?.subtitle.isNotEmpty == true ? user!.subtitle : pharmacy, style: sans(12.5, c: p.mute)),
                if (user?.email.isNotEmpty == true) Text(user!.email, style: sans(12, c: p.mute)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        _group(context, [
          _switchRow(context, 'moon', 'الوضع الداكن', dark,
              (v) => themeMode.value = v ? ThemeMode.dark : ThemeMode.light),
          _switchRow(context, 'bell', 'الإشعارات', _notif, (v) => setState(() => _notif = v)),
          _valueRow(context, 'pin', 'الصيدلية', pharmacy, () {}),
          _valueRow(context, 'user', 'اللغة', 'العربية', () {}, last: true),
        ]),
        const SizedBox(height: 16),
        _group(context, [
          InkWell(
            onTap: _leaving ? null : _logout,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_leaving)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  MfIcon('out', size: 20, color: p.red),
                const SizedBox(width: 8),
                Text('تسجيل الخروج', style: sans(15, w: FontWeight.w700, c: p.red)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 18),
        Center(child: Text('مدفليت · الإصدار 1.2.0', style: sans(11.5, c: p.mute))),
      ],
    );
  }

  Widget _group(BuildContext context, List<Widget> kids) {
    final p = context.mf;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: p.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.line)),
      child: Column(children: kids),
    );
  }

  Widget _ico(BuildContext context, String icon) {
    final p = context.mf;
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: p.greenS, borderRadius: BorderRadius.circular(12)),
      child: Center(child: MfIcon(icon, size: 19, color: p.accent2)),
    );
  }

  Widget _switchRow(BuildContext context, String icon, String label, bool v, ValueChanged<bool> f, {bool last = false}) {
    final p = context.mf;
    return Container(
      decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.line))),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        _ico(context, icon),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: sans(15, c: p.ink))),
        Switch(value: v, onChanged: f, activeColor: Colors.white, activeTrackColor: p.accent),
      ]),
    );
  }

  Widget _valueRow(BuildContext context, String icon, String label, String value, VoidCallback f, {bool last = false}) {
    final p = context.mf;
    return InkWell(
      onTap: f,
      child: Container(
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.line))),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          _ico(context, icon),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: sans(15, c: p.ink))),
          Text(value, style: sans(13, c: p.mute)),
        ]),
      ),
    );
  }
}
