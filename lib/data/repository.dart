import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'models.dart';

abstract class MedFleetRepo {
  MfUser? get user;
  bool get hasSession;
  String? get rememberedEmail;

  Future<void> restore();
  Future<bool> login(String username, String password, {bool remember = true});
  Future<void> logout();

  Future<List<Medicine>> medicines({String? q});
  Future<Medicine?> findMedicine(String q);
  Future<List<ReturnRequest>> returns();
  Future<HomeSnapshot> homeSnapshot();

  Future<List<ScannedInvoice>> recentScans();
  Future<ScannedInvoice?> findScan(String code);
  Future<ScannedInvoice> previewInvoicePhoto(List<int> jpeg);
  Future<void> confirmInvoice(ScannedInvoice invoice);

  Future<void> postCount(List<CountLine> lines, String note);
}

final ApiRepo repo = ApiRepo();

class ApiRepo implements MedFleetRepo {
  ApiRepo() {
    _client.onUnauthorized = _clearLocal;
  }

  final ApiClient _client = ApiClient();
  SharedPreferences? _prefs;
  MfUser? _user;
  String? _rememberedEmail;

  static const _kToken = 'mf_token';
  static const _kRefresh = 'mf_refresh';
  static const _kUser = 'mf_user';
  static const _kEmail = 'mf_email';

  @override
  MfUser? get user => _user;

  @override
  bool get hasSession => (_client.token ?? '').isNotEmpty && _user != null;

  @override
  String? get rememberedEmail => _rememberedEmail;

  Future<SharedPreferences> get _store async => _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<void> restore() async {
    final p = await _store;
    _client.token = p.getString(_kToken);
    _client.refreshToken = p.getString(_kRefresh);
    _rememberedEmail = p.getString(_kEmail);
    final raw = p.getString(_kUser);
    if (raw != null && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw);
        if (json is Map<String, dynamic>) _user = MfUser.fromJson(json);
      } catch (_) {}
    }
  }

  @override
  Future<bool> login(String username, String password, {bool remember = true}) async {
    try {
      final json = await _client.post(
        'auth/login',
        body: {'email': username.trim(), 'password': password},
        auth: false,
      );
      final map = _asMap(json);
      final data = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : map;
      final token = data['token']?.toString();
      if (token == null || token.isEmpty) {
        throw const ApiException('رد تسجيل الدخول ناقص');
      }
      final userJson = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : <String, dynamic>{};
      _client.token = token;
      _client.refreshToken = data['refresh_token']?.toString();
      _user = MfUser.fromJson(userJson);
      final p = await _store;
      await p.setString(_kToken, token);
      await p.setString(_kRefresh, _client.refreshToken ?? '');
      await p.setString(_kUser, jsonEncode(_user!.toJson()));
      if (remember) {
        _rememberedEmail = username.trim();
        await p.setString(_kEmail, username.trim());
      } else {
        _rememberedEmail = null;
        await p.remove(_kEmail);
      }
      return true;
    } on ApiException catch (e) {
      if (e.status == 401) return false;
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      if ((_client.token ?? '').isNotEmpty) {
        await _client.post('auth/logout', body: <String, dynamic>{});
      }
    } catch (_) {}
    await _clearLocal();
  }

  Future<void> _clearLocal() async {
    _client.token = null;
    _client.refreshToken = null;
    _user = null;
    final p = await _store;
    await p.remove(_kToken);
    await p.remove(_kRefresh);
    await p.remove(_kUser);
  }

  @override
  Future<List<Medicine>> medicines({String? q}) async {
    final query = <String, String>{'limit': q == null || q.isEmpty ? '500' : '80'};
    if (q != null && q.trim().isNotEmpty) query['q'] = q.trim();
    final json = await _client.get('buyer/inventory', query: query);
    return _listOf(json).map(Medicine.fromJson).toList();
  }

  @override
  Future<Medicine?> findMedicine(String q) async {
    final code = q.trim();
    if (code.isEmpty) return null;
    final list = await medicines(q: code);
    if (list.isEmpty) return null;
    return list.firstWhere(
      (m) => m.barcode == code || m.lot == code || m.id == code,
      orElse: () => list.first,
    );
  }

  @override
  Future<List<ReturnRequest>> returns() async {
    final json = await _client.get('buyer/purchase-returns');
    return _listOf(json).map(ReturnRequest.fromJson).toList();
  }

  @override
  Future<HomeSnapshot> homeSnapshot() async {
    final results = await Future.wait([medicines(), returns()]);
    final meds = results[0] as List<Medicine>;
    final rets = results[1] as List<ReturnRequest>;
    return HomeSnapshot(
      skuCount: meds.length,
      soon: meds.where((m) => m.status == MedStatus.soon).length,
      expired: meds.where((m) => m.status == MedStatus.expired).length,
      pendingReturns: rets.where((r) => r.status == ReturnStatus.pending).length,
    );
  }

  @override
  Future<List<ScannedInvoice>> recentScans() async {
    final json = await _client.get('buyer/scans');
    return _listOf(json).map(ScannedInvoice.fromScanJson).toList();
  }

  @override
  Future<ScannedInvoice?> findScan(String code) async {
    final q = code.trim().toLowerCase();
    if (q.isEmpty) return null;
    final list = await recentScans();
    for (final s in list) {
      if (s.no.toLowerCase() == q) return s;
    }
    for (final s in list) {
      if (s.no.toLowerCase().contains(q)) return s;
    }
    return null;
  }

  @override
  Future<ScannedInvoice> previewInvoicePhoto(List<int> jpeg) async {
    final json = await _client.uploadImages('buyer/scan/preview', [jpeg]);
    final map = _asMap(json);
    final data = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : map;
    return ScannedInvoice.fromPreview(data);
  }

  @override
  Future<void> confirmInvoice(ScannedInvoice invoice) async {
    if (invoice.alreadyOnServer) return;
    if (invoice.extracted == null) {
      throw const ApiException('ماكو بيانات مستخرجة حتى نعتمد الفاتورة');
    }
    await _client.post('buyer/scan/commit', body: {
      if (invoice.imageUrl != null) 'image_url': invoice.imageUrl,
      'extracted': invoice.extracted,
    });
  }

  @override
  Future<void> postCount(List<CountLine> lines, String note) async {
    final payload = lines.map((l) {
      return {
        'product_id': l.med.id,
        'product_name': l.med.name,
        'barcode': l.med.barcode.isEmpty ? null : l.med.barcode,
        'stock_qty': l.med.qty,
        'current_qty': l.counted,
        'diff_qty': l.diff,
        'unit_cost': l.med.unitCost,
        'diff_value': l.diff * l.med.unitCost,
        'batch_number': l.med.lot == '—' ? null : l.med.lot,
        'expiry_date': l.med.expiryRaw,
      };
    }).toList();
    final total = payload.fold<double>(0, (a, e) => a + ((e['diff_value'] as num?)?.toDouble() ?? 0));
    await _client.post('buyer/inventory/audit/commit', body: {
      'lines': payload,
      if (note.trim().isNotEmpty) 'note': note.trim(),
      'total_diff_value': total,
    });
  }

  Map<String, dynamic> _asMap(dynamic json) => json is Map<String, dynamic> ? json : <String, dynamic>{};

  List<Map<String, dynamic>> _listOf(dynamic json) {
    final map = _asMap(json);
    final data = map['data'] ?? json;
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }
}
