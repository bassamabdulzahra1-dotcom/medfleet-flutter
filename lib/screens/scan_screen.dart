import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../widgets/common.dart';

/// Invoice scanner — camera/gallery preview then commit to MedFleet.
class ScanScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ScanScreen({super.key, required this.onBack});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

enum _Phase { idle, reading, found, confirmed }

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _beam =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  _Phase _phase = _Phase.idle;
  ScannedInvoice? _inv;
  bool _confirming = false;
  List<ScannedInvoice> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    try {
      final list = await repo.recentScans();
      if (mounted) setState(() => _recent = list);
    } catch (_) {}
  }

  void _reset() {
    setState(() {
      _phase = _Phase.idle;
      _inv = null;
      _confirming = false;
    });
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final shot = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2000);
      if (shot == null) return;
      setState(() {
        _phase = _Phase.reading;
        _inv = null;
      });
      final bytes = await shot.readAsBytes();
      final inv = await repo.previewInvoicePhoto(bytes);
      if (!mounted) return;
      setState(() {
        _inv = inv;
        _phase = _Phase.found;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      showMfToast(context, e.toString());
    }
  }

  Future<void> _manual() async {
    final code = await showMfSheet<String>(
      context,
      (c) {
        final t = TextEditingController();
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('رقم الفاتورة', style: kufi(19, c: context.mf.ink)),
          const SizedBox(height: 12),
          TextField(
            controller: t,
            autofocus: true,
            textDirection: TextDirection.ltr,
            onSubmitted: (v) => Navigator.pop(c, v.trim()),
            decoration: const InputDecoration(hintText: 'INV-…'),
          ),
          const SizedBox(height: 14),
          PrimaryButton('بحث', onTap: () => Navigator.pop(c, t.text.trim())),
        ]);
      },
    );
    if (code == null || code.isEmpty) return;
    setState(() => _phase = _Phase.reading);
    try {
      final inv = await repo.findScan(code);
      if (!mounted) return;
      if (inv == null) {
        setState(() => _phase = _Phase.idle);
        showMfToast(context, 'ما لقيت هالفاتورة بالمسح');
        return;
      }
      setState(() {
        _inv = inv;
        _phase = _Phase.found;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      showMfToast(context, e.toString());
    }
  }

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      await repo.confirmInvoice(_inv!);
      if (!mounted) return;
      setState(() {
        _confirming = false;
        _phase = _Phase.confirmed;
      });
      showMfToast(context, _inv!.alreadyOnServer ? 'الفاتورة موجودة بالمسح' : 'أُضيفت الفاتورة للمخزن');
      _loadRecent();
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      showMfToast(context, e.toString());
    }
  }

  @override
  void dispose() {
    _beam.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final done = _phase == _Phase.found || _phase == _Phase.confirmed;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        MfBar(title: 'ماسحة الفاتورة', onBack: widget.onBack),
        const SizedBox(height: 18),
        _Viewfinder(beam: _beam, found: done),
        const SizedBox(height: 18),
        if (_phase == _Phase.reading)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (_phase == _Phase.idle) ...[
          Center(child: Text('صوّر الفاتورة حتى تُقرأ وتدخل للمخزن', style: sans(13, c: p.mute))),
          const SizedBox(height: 14),
          PrimaryButton('التقط صورة الفاتورة', icon: 'scan', onTap: () => _pick(ImageSource.camera)),
          const SizedBox(height: 10),
          PrimaryButton('اختيار من المعرض', ghost: true, onTap: () => _pick(ImageSource.gallery)),
          const SizedBox(height: 10),
          PrimaryButton('إدخال الرقم يدوياً', ghost: true, onTap: _manual),
          if (_recent.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text('آخر المسوحات', style: sans(12, c: p.mute)),
            const SizedBox(height: 8),
            for (final s in _recent.take(6))
              InkWell(
                onTap: () => setState(() {
                  _inv = s;
                  _phase = _Phase.found;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
                  child: Row(children: [
                    Expanded(child: Text('${s.no} · ${s.supplier}', style: sans(13, c: p.ink))),
                    Text(fmtNum(s.total), style: mono(13, c: p.mute)),
                  ]),
                ),
              ),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: p.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: p.greenS, shape: BoxShape.circle),
                  child: Center(child: MfIcon('check', size: 22, color: p.accent)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_phase == _Phase.confirmed ? 'تم إدخال الفاتورة' : 'تم التعرف على الفاتورة',
                        style: kufi(15, c: p.ink)),
                    Text('${_inv!.no} · ${_inv!.supplier}', style: sans(12.5, c: p.mute)),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),
              KvGrid([('عدد الأصناف', '${_inv!.items}'), ('المبلغ (د.ع)', fmtNum(_inv!.total))]),
            ]),
          ),
          const SizedBox(height: 14),
          if (_phase == _Phase.found)
            PrimaryButton(
              _inv!.alreadyOnServer ? 'عرض فقط — موجودة مسبقاً' : 'تأكيد وإدخال للمخزن',
              icon: 'box',
              loading: _confirming,
              onTap: _confirm,
            )
          else
            PrimaryButton('مسح فاتورة أخرى', icon: 'scan', onTap: _reset),
          if (_phase == _Phase.found) ...[
            const SizedBox(height: 10),
            PrimaryButton('إعادة المسح', ghost: true, onTap: _reset),
          ],
        ],
      ],
    );
  }
}

class _Viewfinder extends StatelessWidget {
  final Animation<double> beam;
  final bool found;
  const _Viewfinder({required this.beam, required this.found});

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFF5BE0B3), gold = Color(0xFFF6D77C);
    final corner = found ? gold : mint;
    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF134538), Color(0xFF0B2A22)]),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(alignment: Alignment.center, children: [
        Transform.rotate(angle: -.05, child: const _PaperInvoice()),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 44),
            child: CustomPaint(painter: _Corners(corner)),
          ),
        ),
        if (!found)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: AnimatedBuilder(
                animation: beam,
                builder: (_, __) => Align(
                  alignment: Alignment(0, -.85 + 1.7 * beam.value),
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent, mint, Colors.transparent]),
                      boxShadow: [BoxShadow(color: mint, blurRadius: 18)],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _PaperInvoice extends StatelessWidget {
  const _PaperInvoice();
  @override
  Widget build(BuildContext context) {
    Widget line([double f = 1, Color c = const Color(0xFFC9CFC6), double h = 7]) => FractionallySizedBox(
        widthFactor: f,
        alignment: AlignmentDirectional.centerStart,
        child: Container(height: h, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))));
    return Container(
      width: 176, height: 230,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1E8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 30, offset: Offset(0, 20), spreadRadius: -10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        line(.4, const Color(0xFF0F7B5F), 9),
        const SizedBox(height: 8), line(),
        const SizedBox(height: 8), line(.6),
        const SizedBox(height: 8), line(),
        const SizedBox(height: 8), line(.6),
        const SizedBox(height: 8), line(),
        const Spacer(),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF17261F), width: 5),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Corners extends CustomPainter {
  final Color c;
  _Corners(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final pt = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const l = 30.0;
    void corner(double x, double y, double dx, double dy) {
      canvas.drawPath(
          Path()
            ..moveTo(x, y + dy * l)
            ..lineTo(x, y)
            ..lineTo(x + dx * l, y),
          pt);
    }
    corner(0, 0, 1, 1);
    corner(s.width, 0, -1, 1);
    corner(0, s.height, 1, -1);
    corner(s.width, s.height, -1, -1);
  }

  @override
  bool shouldRepaint(_Corners o) => o.c != c;
}
