import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../Chung/Duong_dan_api.dart';

class LoiApi implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  LoiApi(
    this.message, {
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class GoiApi {
  static String? tokenDangNhap;

  // Alias để các file cũ còn dùng GoiApi.token không bị lỗi.
  static String? get token => tokenDangNhap;
  static set token(String? value) => ganToken(value);

  final Duration timeout;

  GoiApi({
    this.timeout = const Duration(seconds: 25),
  });

  static void ganToken(String? token) {
    final value = token?.trim();
    tokenDangNhap = (value == null || value.isEmpty) ? null : value;
  }

  static void xoaToken() {
    tokenDangNhap = null;
  }

  static bool get coToken => tokenDangNhap != null && tokenDangNhap!.isNotEmpty;

  Uri _uri(String path, {Map<String, dynamic>? query}) {
    final uri = Uri.parse(DuongDanApi.noiApi(path));

    if (query == null || query.isEmpty) return uri;

    final params = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isNotEmpty) params[key] = text;
    });

    if (params.isEmpty) return uri;

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...params,
      },
    );
  }

  Map<String, String> _headers({
    bool json = true,
    String? token,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (json) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    final tokenGuiLen = token ?? tokenDangNhap;
    if (tokenGuiLen != null && tokenGuiLen.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${tokenGuiLen.trim()}';
    }

    return headers;
  }

  dynamic _decode(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return null;

    try {
      return jsonDecode(raw);
    } catch (_) {
      if (raw.startsWith('<')) {
        return {
          'message': 'API trả về HTML. Thường là sai host/route hoặc backend lỗi 500.',
          'raw': raw,
        };
      }
      return raw;
    }
  }

  dynamic _xuLyKetQua(http.Response response) {
    final data = _decode(utf8.decode(response.bodyBytes));

    if (kDebugMode) {
      debugPrint('API ${response.request?.method ?? ''} ${response.request?.url}');
      debugPrint('STATUS ${response.statusCode}');
      debugPrint('BODY ${utf8.decode(response.bodyBytes)}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = 'Có lỗi khi gọi API (${response.statusCode})';

    if (data is Map) {
      message = (data['message'] ?? data['error'] ?? data['msg'] ?? message).toString();
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    throw LoiApi(
      message,
      statusCode: response.statusCode,
      data: data,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await http
        .get(
          _uri(path, query: query),
          headers: _headers(json: false, token: token),
        )
        .timeout(timeout);

    return _xuLyKetQua(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await http
        .post(
          _uri(path, query: query),
          headers: _headers(token: token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(timeout);

    return _xuLyKetQua(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await http
        .put(
          _uri(path, query: query),
          headers: _headers(token: token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(timeout);

    return _xuLyKetQua(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final response = await http
        .patch(
          _uri(path, query: query),
          headers: _headers(token: token),
          body: jsonEncode(body ?? {}),
        )
        .timeout(timeout);

    return _xuLyKetQua(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    final request = http.Request('DELETE', _uri(path, query: query));
    request.headers.addAll(_headers(token: token));
    if (body != null) request.body = jsonEncode(body);

    final streamed = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamed);

    return _xuLyKetQua(response);
  }

  Future<dynamic> getAny(List<String> paths) async {
    Object? loiCuoi;
    for (final path in paths) {
      try {
        return await get(path);
      } catch (e) {
        loiCuoi = e;
      }
    }
    if (loiCuoi is LoiApi) throw loiCuoi;
    throw LoiApi('Không gọi được API');
  }

  Future<dynamic> postAny(
    List<String> paths, {
    Map<String, dynamic>? body,
  }) async {
    Object? loiCuoi;
    for (final path in paths) {
      try {
        return await post(path, body: body);
      } catch (e) {
        loiCuoi = e;
      }
    }
    if (loiCuoi is LoiApi) throw loiCuoi;
    throw LoiApi('Không gọi được API');
  }

  Future<dynamic> patchAny(
    List<String> paths, {
    Map<String, dynamic>? body,
  }) async {
    Object? loiCuoi;
    for (final path in paths) {
      try {
        return await patch(path, body: body);
      } catch (e) {
        loiCuoi = e;
      }
    }
    if (loiCuoi is LoiApi) throw loiCuoi;
    throw LoiApi('Không gọi được API');
  }

  Future<dynamic> putMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
    String? token,
  }) async {
    final request = http.MultipartRequest('PUT', _uri(path));
    request.headers.addAll(_headers(json: false, token: token));
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      final file = File(value);
      if (!file.existsSync()) continue;
      request.files.add(await http.MultipartFile.fromPath(entry.key, value));
    }

    final streamed = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    return _xuLyKetQua(response);
  }

  Future<dynamic> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, String> files = const {},
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headers(json: false, token: token));
    request.fields.addAll(fields);

    for (final entry in files.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      final file = File(value);
      if (!file.existsSync()) continue;
      request.files.add(await http.MultipartFile.fromPath(entry.key, value));
    }

    final streamed = await request.send().timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    return _xuLyKetQua(response);
  }
}
