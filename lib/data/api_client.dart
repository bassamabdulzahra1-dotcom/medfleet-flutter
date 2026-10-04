import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

class ApiClient {
  static const baseUrl = 'https://medfleet.net/api/v1';

  String? token;
  String? refreshToken;
  Future<void> Function()? onUnauthorized;

  Future<bool>? _refreshing;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl/$path').replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> uploadImages(String path, List<List<int>> images) async {
    Future<http.StreamedResponse> sendWith(String? bearer) {
      final req = http.MultipartRequest('POST', _uri(path));
      req.headers['Accept'] = 'application/json';
      if (bearer != null && bearer.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $bearer';
      }
      for (var i = 0; i < images.length; i++) {
        req.files.add(http.MultipartFile.fromBytes(
          'images',
          images[i],
          filename: 'invoice_$i.jpg',
        ));
      }
      return req.send();
    }

    var streamed = await sendWith(token);
    var res = await http.Response.fromStream(streamed);
    if (res.statusCode == 401) {
      final ok = await _refresh();
      if (ok) {
        streamed = await sendWith(token);
        res = await http.Response.fromStream(streamed);
      } else {
        await onUnauthorized?.call();
        throw const ApiException('انتهت الجلسة. سجّل دخولك مرة ثانية', 401);
      }
    }
    return _decode(res);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    Future<http.Response> once(String? bearer) {
      final headers = <String, String>{
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
        if (auth && bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      };
      final uri = _uri(path, query);
      switch (method) {
        case 'POST':
          return http.post(uri, headers: headers, body: body == null ? null : jsonEncode(body));
        default:
          return http.get(uri, headers: headers);
      }
    }

    var res = await once(auth ? token : null);
    if (res.statusCode == 401 && auth && !path.contains('auth/login') && !path.contains('auth/refresh')) {
      final ok = await _refresh();
      if (ok) {
        res = await once(token);
      } else {
        await onUnauthorized?.call();
        throw const ApiException('انتهت الجلسة. سجّل دخولك مرة ثانية', 401);
      }
    }
    return _decode(res);
  }

  Future<bool> _refresh() async {
    if (_refreshing != null) return _refreshing!;
    final refresh = refreshToken;
    if (refresh == null || refresh.isEmpty) return false;
    final pending = () async {
      try {
        final res = await http.post(
          _uri('auth/refresh'),
          headers: const {'Accept': 'application/json', 'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': refresh}),
        );
        if (res.statusCode != 200) return false;
        final json = jsonDecode(res.body);
        if (json is! Map<String, dynamic>) return false;
        final next = json['token']?.toString();
        if (next == null || next.isEmpty) return false;
        token = next;
        return true;
      } catch (_) {
        return false;
      } finally {
        _refreshing = null;
      }
    }();
    _refreshing = pending;
    return pending;
  }

  dynamic _decode(http.Response res) {
    dynamic json;
    if (res.body.isNotEmpty) {
      try {
        json = jsonDecode(res.body);
      } catch (_) {
        json = null;
      }
    }
    if (res.statusCode >= 400) {
      final msg = _errorMessage(json) ?? _fallback(res.statusCode);
      throw ApiException(msg, res.statusCode);
    }
    return json;
  }

  String? _errorMessage(dynamic json) {
    if (json is Map<String, dynamic>) {
      final m = json['message'] ?? json['error'];
      if (m is String && m.trim().isNotEmpty) return m.trim();
    }
    return null;
  }

  String _fallback(int status) {
    if (status == 401) return 'اسم المستخدم أو كلمة المرور غير صحيحة';
    if (status == 403) return 'ما عندك صلاحية لهذا الإجراء';
    if (status == 404) return 'ما لقيت المطلوب';
    if (status >= 500) return 'السيرفر مشغول، حاول بعد شوية';
    return 'تعذر إكمال الطلب ($status)';
  }
}
