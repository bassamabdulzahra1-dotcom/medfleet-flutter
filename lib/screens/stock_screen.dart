import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../widgets/common.dart';

/// Status pill colours/labels for a medicine.
Widget medPill(BuildContext context, Medicine m) {
  final p = context.mf;
  switch (m.status) {
    case MedStatus.ok:
      return Pill('متوفر', bg: p.greenS, fg: p.accent);
    case MedStatus.soon:
      return Pill('ينتهي قريباً', bg: p.goldS, fg: p.gold);
    case MedStatus.low:
      return Pill('كمية قليلة', bg: p.goldS, fg: p.gold);
    case MedStatus.expired:
      return Pill('منتهي', bg: p.redS, fg: p.red);
  }
}

class StockScreen extends StatefulWidget {
  final VoidCallback onBack;
  const StockScreen({super.key, required this.onBack});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final _q = TextEditingController();
  List<Medicine> _all = [];
  MedStatus? _filter; // null = all
  bool _loading = true;
  String? _error;

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
      final v = await repo.medicines(q: _q.text.trim().isEmpty ? null : _q.text.trim());
      if (!mounted) return;
      setState(() {
        _all = v;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<Medicine> get _list {
    final q = _q.text.trim().toLowerCase();
    return _all.where((m) {
      if (_filter != null && m.status != _filter) return false;
      return q.isEmpty ||
          m.name.contains(q) ||
          m.lot.toLowerCase().contains(q) ||
          m.barcode.toLowerCase().contains(q);
    }).toList();
  }

  void _detail(Medicine m) {
    final p = context.mf;
    showMfSheet(context, (c) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(m.name, style: kufi(19, c: p.ink)),
          const SizedBox(height: 8),
          Align(alignment: AlignmentDirectional.centerStart, child: medPill(context, m)),
          const SizedBox(height: 14),
          KvGrid([
            ('الكمية', '${m.qty}'),
            if (repo.user?.canSeePrices != false) ('السعر (د.ع)', fmtNum(m.price)),
            ('رقم الوجبة', m.lot),
            ('تاريخ الانتهاء', m.expiry),
          ]),
          const SizedBox(height: 16),
          PrimaryButton('تم', onTap: () => Navigator.pop(c)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final list = _list;
    int cnt(MedStatus? s) => s == null ? _all.length : _all.where((m) => m.status == s).length;
    final chips = <(MedStatus?, String)>[
      (null, 'الكل'),
      (MedStatus.soon, 'قريب الانتهاء'),
      (MedStatus.low, 'ناقص'),
      (MedStatus.expired, 'منتهي'),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        MfBar(title: 'المخزن', onBack: widget.onBack),
        const SizedBox(height: 18),
        MfSearchField(controller: _q, hint: 'ابحث باسم الدواء أو الباركود', onChanged: (_) => setState(() {})),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (final (s, l) in chips)
              MfChip(l, count: cnt(s), on: _filter == s, onTap: () => setState(() => _filter = s)),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          _kpi(context, '${list.length}', 'نتيجة', p.ink),
          const SizedBox(width: 10),
          _kpi(context, '${list.where((m) => m.status == MedStatus.soon).length}', 'تنتهي قريباً', p.gold),
          const SizedBox(width: 10),
          _kpi(context, '${list.where((m) => m.status == MedStatus.expired).length}', 'منتهية', p.red),
        ]),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(36),
            child: Center(
              child: GestureDetector(onTap: _load, child: Text(_error!, style: sans(14, c: p.red))),
            ),
          )
        else if (list.isEmpty)
          Padding(padding: const EdgeInsets.all(36), child: Center(child: Text('ما لقيت نتيجة', style: sans(14, c: p.mute))))
        else
          for (var i = 0; i < list.length; i++) _medRow(context, list[i], i == list.length - 1),
      ],
    );
  }

  Widget _kpi(BuildContext context, String n, String l, Color c) {
    final p = context.mf;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n, style: mono(22, c: c)),
          Text(l, style: sans(11.5, c: p.mute)),
        ]),
      ),
    );
  }

  Widget _medRow(BuildContext context, Medicine m, bool last) {
    final p = context.mf;
    return InkWell(
      onTap: () => _detail(m),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: p.line))),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: p.greenS, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Text('${m.qty}', style: mono(17, c: p.accent2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: sans(15, w: FontWeight.w700, c: p.ink)),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text('LOT ${m.lot} · EXP ${m.expiry}', style: mono(12, w: FontWeight.w500, c: p.mute)),
              ),
            ]),
          ),
          medPill(context, m),
        ]),
      ),
    );
  }
}
