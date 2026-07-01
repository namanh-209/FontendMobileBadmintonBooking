import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Danh_gia.dart';

class DanhGiaApi {
  static Future<String> _layToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('token') ??
        prefs.getString('accessToken') ??
        prefs.getString('jwt') ??
        prefs.getString('auth_token') ??
        '';
  }

  static Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static List _layList(dynamic body) {
    if (body is List) return body;

    if (body is Map) {
      if (body['danh_sach'] is List) return body['danh_sach'];
      if (body['data'] is List) return body['data'];
      if (body['danh_gia'] is List) return body['danh_gia'];

      if (body['data'] is Map) {
        final data = body['data'];
        if (data['danh_sach'] is List) return data['danh_sach'];
        if (data['danh_gia'] is List) return data['danh_gia'];
      }
    }

    return [];
  }

  static Future<List<DanhGia>> layDanhSachDanhGia(int coSoId) async {
    final url = Uri.parse(
      DuongDanApi.noiApi(DuongDanApi.danhSachDanhGia(coSoId)),
    );

    final response = await http
        .get(url)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Lỗi ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final list = _layList(body);

    return list
        .whereType<Map>()
        .map((e) => DanhGia.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> guiDanhGia({
    required int coSoId,
    required int soSao,
    required String noiDung,
  }) async {
    final token = await _layToken();

    if (token.isEmpty) {
      throw Exception('Bạn cần đăng nhập để đánh giá');
    }

    final url = Uri.parse(
      DuongDanApi.noiApi(DuongDanApi.themDanhGia),
    );

    final response = await http
        .post(
          url,
          headers: _headers(token),
          body: jsonEncode({
            'co_so_id': coSoId,
            'so_sao': soSao,
            'noi_dung': noiDung,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi ${response.statusCode}: ${response.body}');
    }
  }
}