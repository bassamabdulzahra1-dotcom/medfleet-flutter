enum MedStatus { ok, soon, low, expired }

class Medicine {
  final String id;
  final String name;
  final String lot;
  final String expiry; // MM/YYYY
  final int qty;
  final int daysLeft; // negative = already expired
  final int price; // IQD
  final String barcode;
  final double unitCost;
  final String? expiryRaw;

  const Medicine({
    required this.id,
    required this.name,
    required this.lot,
    required this.expiry,
    required this.qty,
    required this.daysLeft,
    required this.price,
    this.barcode = '',
    this.unitCost = 0,
    this.expiryRaw,
  });

  MedStatus get status {
    if (daysLeft < 0) return MedStatus.expired;
    if (daysLeft <= 60) return MedStatus.soon;
    if (qty <= 20) return MedStatus.low;
    return MedStatus.ok;
  }

  factory Medicine.fromJson(Map<String, dynamic> j) {
    final expiryRaw = _asStr(j['expiry_date']);
    final qty = _asNum(j['qty_on_hand']).round();
    final price = _asNum(j['sale_price']).round();
    final cost = _asNum(j['standard_cost']);
    final barcode = _asStr(j['barcode']);
    final lot = _asStr(j['batch_number']).isNotEmpty ? _asStr(j['batch_number']) : (barcode.isNotEmpty ? barcode : '—');
    return Medicine(
      id: _asStr(j['id']),
      name: _asStr(j['name']).isNotEmpty ? _asStr(j['name']) : 'صنف',
      lot: lot,
      expiry: _fmtExpiry(expiryRaw),
      qty: qty,
      daysLeft: _daysLeft(expiryRaw),
      price: price,
      barcode: barcode,
      unitCost: cost > 0 ? cost : price.toDouble(),
      expiryRaw: expiryRaw.isEmpty ? null : expiryRaw,
    );
  }
}

enum ReturnStatus { pending, approved, rejected }

class ReturnRequest {
  final String id;
  final String supplier;
  final int items;
  final int value; // IQD
  final ReturnStatus status;
  const ReturnRequest({
    required this.id,
    required this.supplier,
    required this.items,
    required this.value,
    required this.status,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> j) {
    final lines = j['lines'];
    final itemCount = lines is List ? lines.length : _asNum(j['line_count']).round();
    return ReturnRequest(
      id: _asStr(j['ref']).isNotEmpty ? _asStr(j['ref']) : _asStr(j['id']),
      supplier: _asStr(j['vendor_name']).isNotEmpty ? _asStr(j['vendor_name']) : 'مجهّز',
      items: itemCount,
      value: _asNum(j['amount_total']).round(),
      status: _returnStatus(_asStr(j['status'])),
    );
  }
}

class ScannedInvoice {
  final String no;
  final String supplier;
  final int items;
  final int total; // IQD
  final String? imageUrl;
  final Map<String, dynamic>? extracted;
  final bool alreadyOnServer;

  const ScannedInvoice({
    required this.no,
    required this.supplier,
    required this.items,
    required this.total,
    this.imageUrl,
    this.extracted,
    this.alreadyOnServer = false,
  });

  factory ScannedInvoice.fromScanJson(Map<String, dynamic> j) {
    return ScannedInvoice(
      no: _firstStr(j, const ['vendor_ref', 'ref', 'id']),
      supplier: _asStr(j['supplier_name']).isNotEmpty ? _asStr(j['supplier_name']) : 'مجهّز',
      items: _asNum(j['line_count']).round(),
      total: _asNum(j['amount_total']).round(),
      imageUrl: _asStr(j['scan_image_url']).isEmpty ? null : _asStr(j['scan_image_url']),
      alreadyOnServer: true,
    );
  }

  factory ScannedInvoice.fromPreview(Map<String, dynamic> data) {
    final extracted = data['extracted'] is Map<String, dynamic> ? data['extracted'] as Map<String, dynamic> : <String, dynamic>{};
    final lines = data['lines'] is List ? data['lines'] as List : const [];
    final no = _firstStr(data, const ['vendor_ref', 'ref']);
    return ScannedInvoice(
      no: no.isNotEmpty ? no : 'فاتورة جديدة',
      supplier: _firstStr(data, const ['supplier_name']).isNotEmpty
          ? _firstStr(data, const ['supplier_name'])
          : 'مجهّز',
      items: lines.length,
      total: _asNum(data['amount_total']).round(),
      imageUrl: _asStr(data['image_url']).isEmpty ? null : _asStr(data['image_url']),
      extracted: extracted,
    );
  }
}

/// One line in a stock count: the medicine and how many were physically counted.
class CountLine {
  final Medicine med;
  int counted;
  CountLine(this.med, this.counted);

  int get diff => counted - med.qty;
  int get value => diff * med.price;
}

class MfUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String appRole;
  final bool canSeePrices;
  final String pharmacyName;
  final String branch;

  const MfUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.appRole,
    required this.canSeePrices,
    this.pharmacyName = '',
    this.branch = '',
  });

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  String get initial {
    final t = name.trim();
    return t.isEmpty ? 'م' : t.substring(0, 1);
  }

  String get roleLabel {
    if (role == 'buyer' && appRole == 'employee') return 'موظف';
    if (role == 'buyer') return 'صيدلي';
    if (role == 'rep') return 'مندوب';
    return role.isEmpty ? 'مستخدم' : role;
  }

  String get subtitle {
    final bits = <String>[roleLabel];
    if (pharmacyName.isNotEmpty) bits.add(pharmacyName);
    if (branch.isNotEmpty) bits.add(branch);
    return bits.join(' · ');
  }

  factory MfUser.fromJson(Map<String, dynamic> j) {
    final role = _asStr(j['role']);
    final appRole = _asStr(j['app_role']).isEmpty ? 'manager' : _asStr(j['app_role']);
    final prices = j['can_see_prices'];
    final canSee = prices is bool
        ? prices
        : !(role == 'buyer' && appRole == 'employee');
    final pharmacy = j['pharmacy'];
    return MfUser(
      id: _asStr(j['id']),
      email: _asStr(j['email']),
      name: _asStr(j['name']).isEmpty ? _asStr(j['email']) : _asStr(j['name']),
      role: role,
      appRole: appRole,
      canSeePrices: canSee,
      pharmacyName: _firstStr(j, const ['pharmacy_name', 'company_name', 'office_name', 'tenant_name']).isNotEmpty
          ? _firstStr(j, const ['pharmacy_name', 'company_name', 'office_name', 'tenant_name'])
          : (pharmacy is Map<String, dynamic> ? _asStr(pharmacy['name']) : ''),
      branch: _firstStr(j, const ['branch', 'branch_name', 'region', 'area']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'app_role': appRole,
        'can_see_prices': canSeePrices,
        'pharmacy_name': pharmacyName,
        'branch': branch,
      };
}

class HomeSnapshot {
  final int skuCount;
  final int soon;
  final int expired;
  final int pendingReturns;
  const HomeSnapshot({
    required this.skuCount,
    required this.soon,
    required this.expired,
    required this.pendingReturns,
  });
}

class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, [this.status]);

  bool get unauthorized => status == 401;

  @override
  String toString() => message;
}

String _asStr(Object? v) => v == null ? '' : v.toString().trim();

double _asNum(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
}

String _firstStr(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final s = _asStr(j[k]);
    if (s.isNotEmpty) return s;
  }
  return '';
}

ReturnStatus _returnStatus(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('reject') || s.contains('cancel') || s.contains('refuse') || s.contains('رفض')) {
    return ReturnStatus.rejected;
  }
  if (s.contains('approv') || s.contains('accept') || s.contains('done') || s.contains('post') || s.contains('قبول')) {
    return ReturnStatus.approved;
  }
  return ReturnStatus.pending;
}

String _fmtExpiry(String raw) {
  if (raw.isEmpty) return '—';
  final iso = DateTime.tryParse(raw);
  if (iso != null) {
    final m = iso.month.toString().padLeft(2, '0');
    return '$m/${iso.year}';
  }
  final slash = RegExp(r'^(\d{1,2})[/-](\d{4})$').firstMatch(raw);
  if (slash != null) {
    return '${slash.group(1)!.padLeft(2, '0')}/${slash.group(2)}';
  }
  return raw;
}

int _daysLeft(String raw) {
  if (raw.isEmpty) return 9999;
  var dt = DateTime.tryParse(raw);
  if (dt == null) {
    final slash = RegExp(r'^(\d{1,2})[/-](\d{4})$').firstMatch(raw);
    if (slash != null) {
      final month = int.parse(slash.group(1)!);
      final year = int.parse(slash.group(2)!);
      dt = DateTime(year, month + 1, 0);
    }
  }
  if (dt == null) return 9999;
  return DateTime(dt.year, dt.month, dt.day).difference(DateTime.now()).inDays;
}
