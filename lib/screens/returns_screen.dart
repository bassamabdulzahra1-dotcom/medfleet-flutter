import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/icons.dart';
import '../core/tokens.dart';
import '../data/models.dart';
import '../data/repository.dart';
import '../widgets/common.dart';

/// Purchase returns. Pushed from Home (own Scaffold).
class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});
  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  List<ReturnRequest> _all = [];
  ReturnStatus _tab = ReturnStatus.pending;

  @override
  void initState() {
    super.initState();
    repo.returns().then((v) {
      if (mounted) setState(() => _all = v);
    });
  }

  static const _labels = {
    ReturnStatus.pending: 'قيد المراجعة',
    ReturnStatus.approved: 'مقبول',
    ReturnStatus.rejected: 'مرفوض',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.mf;
    final list = _all.where((r) => r.status == _tab).toList();
    Pill statusPill(ReturnStatus s) => switch (s) {
          ReturnStatus.pending => Pill(_labels[s]!, bg: p.goldS, fg: p.gold),
          ReturnStatus.approved => Pill(_labels[s]!, bg: p.greenS, fg: p.accent),
          ReturnStatus.rejected => Pill(_labels[s]!, bg: p.redS, fg: p.red),
        };
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                MfBar(title: 'مردود الشراء', onBack: () => Navigator.pop(context)),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final s in ReturnStatus.values)
                      MfChip(_labels[s]!,
                          count: _all.where((r) => r.status == s).length,
                          on: _tab == s,
                          onTap: () => setState(() => _tab = s)),
                  ]),
                ),
                const SizedBox(height: 14),
                for (final r in list)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: p.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: p.line)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(r.id, style: mono(15, c: p.ink)),
                        statusPill(r.status),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        MfIcon('truck', size: 18, color: p.accent),
                        const SizedBox(width: 8),
                        Text(r.supplier, style: sans(13, c: p.mute)),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: p.line))),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${r.items} أصناف', style: sans(12.5, c: p.mute)),
                          Row(children: [
                            Text('القيمة ', style: sans(12.5, c: p.mute)),
                            Text(fmtNum(r.value), style: mono(14, c: p.ink)),
                            Text(' د.ع', style: sans(12.5, c: p.mute)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                const SizedBox(height: 4),
                // TODO: new-return flow
                PrimaryButton('طلب مردود جديد', icon: 'plus', onTap: () => showMfToast(context, 'طلب مردود جديد · قيد التصميم')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
