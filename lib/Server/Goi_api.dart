import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Chung/Duong_dan_api.dart';

class LoiApi implements Exception {
  final int? statusCode;
  final String message;

  LoiApi(this.message, {this.statusCode});

  @override
  String toString() {
    return message;
  }
}

class GoiApi {
  static String? token;

  static Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }

    return h;
  }

  static Map<String, String> get _headersMultipart {
    final h = <String, String>{
      'Accept': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }

    return h;
  }

  static Uri _uri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }

    return Uri.parse('${DuongDanApi.goc}$path');
  }

  static dynamic _decode(String body) {
    final value = body.trim();
    if (value.isEmpty) return null;

    try {
      return jsonDecode(value);
    } catch (_) {
      return value;
    }
  }

  static dynamic _xuLy(http.Response res) {
    final data = _decode(res.body);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }

    String msg = 'Lỗi kết nối API (${res.statusCode})';

    if (data is Map) {
      msg = (data['message'] ?? data['error'] ?? data['msg'] ?? msg).toString();
    } else if (data is String && data.isNotEmpty) {
      if (data.trimLeft().startsWith('<')) {
        msg = 'API trả về HTML (${res.statusCode}), kiểm tra lại endpoint hoặc server';
      } else {
        msg = data;
      }
    }

    throw LoiApi(msg, statusCode: res.statusCode);
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(
      _uri(path),
      headers: _headers,
    );

    return _xuLy(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _xuLy(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _xuLy(res);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _xuLy(res);
  }

  static Future<dynamic> delete(String path) async {
    final res = await http.delete(
      _uri(path),
      headers: _headers,
    );

    return _xuLy(res);
  }

  static Future<dynamic> putMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
  }) async {
    final request = http.MultipartRequest('PUT', _uri(path));
    request.headers.addAll(_headersMultipart);
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      if (entry.value.trim().isEmpty) continue;
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    return _xuLy(res);
  }

  static Future<dynamic> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headersMultipart);
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      if (entry.value.trim().isEmpty) continue;
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    return _xuLy(res);
  }

  static Future<dynamic> getAny(List<String> paths) async {
    Object? lastError;

    for (final p in paths) {
      try {
        return await get(p);
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? LoiApi('Không gọi được API');
  }

  static Future<dynamic> postAny(
    List<String> paths,
    Map<String, dynamic> body,
  ) async {
    Object? lastError;

    for (final p in paths) {
      try {
        return await post(p, body);
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? LoiApi('Không gọi được API');
  }

  static Future<dynamic> putAny(
    List<String> paths,
    Map<String, dynamic> body,
  ) async {
    Object? lastError;

    for (final p in paths) {
      try {
        return await put(p, body);
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? LoiApi('Không gọi được API');
  }

  static Future<dynamic> patchAny(
    List<String> paths,
    Map<String, dynamic> body,
  ) async {
    Object? lastError;

    for (final p in paths) {
      try {
        return await patch(p, body);
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? LoiApi('Không gọi được API');
  }

  static Future<dynamic> deleteAny(List<String> paths) async {
    Object? lastError;

    for (final p in paths) {
      try {
        return await delete(p);
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? LoiApi('Không gọi được API');
  }
}
