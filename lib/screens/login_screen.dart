import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/repository.dart';
import '../widgets/common.dart';
import 'shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _u = TextEditingController();
  final _pw = TextEditingController();
  bool _hide = true, _remember = true, _loading = false;
  String? _error;
  bool _badU = false, _badP = false;
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  @override
  void dispose() {
    _u.dispose();
    _pw.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _fail(String msg, {bool u = false, bool p = false}) {
    setState(() {
      _error = msg;
      _badU = u;
      _badP = p;
    });
    _shake.forward(from: 0);
  }

  Future<void> _submit() async {
    final u = _u.text.trim(), pw = _pw.text;
    if (u.isEmpty && pw.isEmpty) return _fail('أدخل اسم المستخدم وكلمة المرور', u: true, p: true);
    if (u.isEmpty) return _fail('أدخل اسم المستخدم', u: true);
    if (pw.isEmpty) return _fail('أدخل كلمة المرور', p: true);
    setState(() {
      _loading = true;
      _error = null;
      _badU = _badP = false;
    });
    final ok = await repo.login(u, pw); // TODO(api): handle network errors
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
    } else {
      _fail('اسم المستخدم أو كلمة المرور غير صحيحة', u: true, p: true);
    }
  }

  Widget _field(String label, TextEditingController c, String icon,
      {bool obscure = false, bool bad = false, Widget? suffix, String hint = ''}) {
    final p = context.mf;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: sans(13, c: p.mute)),
      const SizedBox(height: 6),
      Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: bad ? p.red : p.line, width: 1.5),
        ),
        child: Row(children: [
          MfIcon(icon, size: 18, color: p.mute),
          const SizedBox(width: 10),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: c,
                obscureText: obscure,
                onChanged: (_) => setState(() => _error = null),
                autocorrect: false,
                textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
                onSubmitted: obscure ? (_) => _submit() : null,
                style: sans(15, w: FontWeight.w500, c: p.ink),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: hint,
                    hintStyle: sans(15, c: p.mute.withOpacity(.6))),
              ),
            ),
          ),
          if (suffix != null) suffix,
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: const Alignment(0, .1), colors: [p.m1, p.bg]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const SizedBox(height: 12),
                  const Center(child: BrandMark(size: 72)),
                  const SizedBox(height: 8),
                  const Center(child: Wordmark()),
                  const SizedBox(height: 36),
                  Text('أهلاً بعودتك', style: kufi(24, c: p.ink)),
                  const SizedBox(height: 2),
                  Text('سجّل الدخول لإدارة صيدليتك', style: sans(14, c: p.mute)),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (_, child) {
                      final dx = math.sin(_shake.value * math.pi * 4) * 7 * (1 - _shake.value);
                      return Transform.translate(offset: Offset(dx, 0), child: child);
                    },
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      _field('اسم المستخدم', _u, 'user', bad: _badU, hint: 'bakr.amer'),
                      const SizedBox(height: 14),
                      _field('كلمة المرور', _pw, 'lock',
                          obscure: _hide,
                          bad: _badP,
                          hint: '••••••••',
                          suffix: GestureDetector(
                              onTap: () => setState(() => _hide = !_hide),
                              child: MfIcon('eye', size: 20, color: p.mute))),
                    ]),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: p.redS, borderRadius: BorderRadius.circular(12)),
                      child: Text(_error!, style: sans(13, c: p.red)),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(children: [
                    SizedBox(
                      width: 22, height: 22,
                      child: Checkbox(
                        value: _remember,
                        activeColor: p.accent,
                        onChanged: (v) => setState(() => _remember = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('تذكرني', style: sans(13, c: p.mute)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => showMfToast(context, 'راسل مدير الصيدلية لإعادة تعيين كلمة المرور'),
                      child: Text('نسيت كلمة المرور؟', style: sans(13, w: FontWeight.w700, c: p.accent)),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  PrimaryButton('تسجيل الدخول', onTap: _submit, loading: _loading),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: Divider(color: p.line)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('أو', style: sans(12, c: p.mute))),
                    Expanded(child: Divider(color: p.line)),
                  ]),
                  const SizedBox(height: 14),
                  // TODO(biometric): wire up local_auth
                  PrimaryButton('الدخول بالبصمة', ghost: true, icon: 'fp', onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
                  }),
                  const SizedBox(height: 22),
                  Center(child: Text('مدفليت · الإصدار 1.0', style: sans(12, c: p.mute))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
