import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../widgets/common.dart';

/// Stock count: fast barcode + manual entry + financial difference.
class CountScreen extends StatefulWidget {
  final VoidCallback onBack;
  const CountScreen({super.key, required this.onBack});
  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  final _q = TextEditingController();
  final _note = TextEditingController();
  List<Medicine> _meds = [];
  final List<CountLine> _lines = [];
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    repo.medicines().then((v) {
      if (mounted) setState(() => _meds = v);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _q.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _total => _lines.fold(0, (a, l) => a + l.value);

  void _add(Medicine m, [int inc = 1]) {
    setState(() {
      final i = _lines.indexWhere((l) => l.med.id == m.id);
      if (i >= 0) {
        _lines[i].counted += inc;
      } else {
        _lines.insert(0, CountLine(m, inc));
      }
    });
  }

  Future<void> _scan() async {
    final code = await showMfSheet<String>(
      context,
      (c) {
        final t = TextEditingController();
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('بحث بالباركود', style: kufi(19, c: context.mf.ink)),
          const SizedBox(height: 12),
          TextField(
            controller: t,
            autofocus: true,
            textDirection: TextDirection.ltr,
            onSubmitted: (v) => Navigator.pop(c, v.trim()),
            decoration: const InputDecoration(hintText: 'أدخل الباركود أو رقم الوجبة'),
          ),
          const SizedBox(height: 14),
          PrimaryButton('بحث', onTap: () => Navigator.pop(c, t.text.trim())),
        ]);
      },
    );
    if (code == null || code.isEmpty) return;
    try {
      final m = await repo.findMedicine(code);
      if (!mounted) return;
      if (m == null) {
        showMfToast(context, 'ما لقيت هذا الصنف بالمخزن');
        return;
      }
      _add(m);
      showMfToast(context, 'تمت إضافة ${m.name}');
    } catch (e) {
      if (!mounted) return;
      showMfToast(context, e.toString());
    }
  }

  List<Medicine> get _results {
    final q = _q.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _meds
        .where((m) =>
            m.name.contains(q) ||
            m.lot.toLowerCase().contains(q) ||
            m.barcode.toLowerCase().contains(q))
        .take(4)
        .toList();
  }

  Future<void> _post() async {
    final p = context.mf;
    final ok = await showMfSheet<bool>(
      context,
      (c) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('ترحيل الفرق للحسابات', style: kufi(19, c: p.ink)),
        const SizedBox(height: 14),
        KvGrid([('الأصناف', '${_lines.length}'), ('القيمة المالية', fmtMoney(_total))]),
        if (_note.text.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('الملاحظة: ${_note.text.trim()}', style: sans(13, c: p.mute)),
        ],
        const SizedBox(height: 16),
        PrimaryButton('تأكيد الترحيل', onTap: () => Navigator.pop(c, true)),
        const SizedBox(height: 10),
        PrimaryButton('إلغاء', ghost: true, onTap: () => Navigator.pop(c, false)),
      ]),
    );
    if (ok != true) return;
    setState(() => _posting = true);
    try {
      await repo.postCount(_lines, _note.text.trim());
      if (!mounted) return;
      setState(() {
        _posting = false;
        _lines.clear();
        _note.clear();
      });
      showMfToast(context, 'تم ترحيل الفرق للحسابات');
    } catch (e) {
      if (!mounted) return;
      setState(() => _posting = false);
      showMfToast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final res = _results;
    final total = _total;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        MfBar(title: 'الجرد المخزني', subtitle: 'باركود سريع + إدخال يدوي + فرق مالي', onBack: widget.onBack),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Material(
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _scan,
              child: Ink(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [p.l1, p.l3])),
                child: Row(children: [
                  MfIcon('scan', size: 22, color: Colors.white, gold: p.goldOnTile),
                  const SizedBox(width: 8),
                  Text('مسح باركود', style: kufi(14, c: Colors.white)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MfSearchField(controller: _q, hint: 'اكتب اسم المنتج أو...', onChanged: (_) => setState(() {})),
          ),
        ]),
        if (res.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
                color: p.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.line)),
            child: Column(children: [
              for (final m in res)
                InkWell(
                  onTap: () {
                    _add(m);
                    _q.clear();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(children: [
                      Expanded(child: Text(m.name, style: sans(14, w: FontWeight.w500, c: p.ink))),
                      Text(m.lot, style: mono(11.5, w: FontWeight.w500, c: p.mute)),
                    ]),
                  ),
                ),
            ]),
          ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: p.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ملخص الفروقات', style: kufi(16, c: p.ink)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text('القيمة المالية: ', style: sans(14, c: p.ink)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(fmtMoney(total),
                        style: mono(16, c: total < 0 ? p.red : (total > 0 ? p.accent : p.ink))),
                  ),
                ]),
              ),
              Text('أصناف مسجلة', style: sans(12.5, c: p.mute)),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(minWidth: 28),
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: p.greenS, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text('${_lines.length}', style: mono(13, c: p.accent2)),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              style: sans(14, c: p.ink),
              decoration: InputDecoration(
                hintText: 'ملاحظة القيد المحاسبي (اختياري)',
                hintStyle: sans(14, c: p.mute),
                filled: true,
                fillColor: p.bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line, width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.accent, width: 1.5)),
              ),
            ),
          ]),
        ),
        if (_lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 34),
            child: Column(children: [
              const IconTile('box', size: 62),
              const SizedBox(height: 12),
              Text('ابدأ بالمسح أو البحث لإضافة الأصناف', style: sans(13.5, c: p.mute)),
            ]),
          )
        else
          for (var i = 0; i < _lines.length; i++) _lineRow(context, i),
        const SizedBox(height: 16),
        PrimaryButton('ترحيل الفرق للحسابات',
            icon: 'check', loading: _posting, onTap: _lines.isEmpty ? null : _post),
      ],
    );
  }

  Widget _lineRow(BuildContext context, int i) {
    final p = context.mf;
    final l = _lines[i];
    final d = l.diff;
    final dc = d == 0 ? p.accent : (d.abs() <= 2 ? p.gold : p.red);
    final dbg = d == 0 ? p.greenS : (d.abs() <= 2 ? p.goldS : p.redS);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.med.name, style: sans(15, w: FontWeight.w700, c: p.ink)),
              Text('الباركود ${l.med.lot} · بالنظام ${l.med.qty}', style: sans(12, c: p.mute)),
            ]),
          ),
          IconButton(
            onPressed: () => setState(() => _lines.removeAt(i)),
            icon: RotatedBox(quarterTurns: 1, child: MfIcon('plus', size: 18, color: p.mute)),
            tooltip: 'حذف',
          ),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Stepper3(value: l.counted, onChanged: (v) => setState(() => l.counted = v)),
          Pill(d == 0 ? 'مطابق' : (d > 0 ? '+$d' : '$d'), bg: dbg, fg: dc),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(fmtMoney(l.value), style: mono(15, c: l.value < 0 ? p.red : (l.value > 0 ? p.accent : p.ink))),
          ),
        ]),
      ]),
    );
  }
}
