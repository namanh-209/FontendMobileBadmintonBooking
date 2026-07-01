import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Thong_bao.dart';

class ThongBaoApi 
{
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
    if (body['danh_sach'] is List) {
      return body['danh_sach'];
    }

    if (body['data'] is List) {
      return body['data'];
    }

    if (body['thong_bao'] is List) {
      return body['thong_bao'];
    }

    if (body['notifications'] is List) {
      return body['notifications'];
    }

    if (body['result'] is List) {
      return body['result'];
    }

    if (body['data'] is Map) {
      final data = body['data'];

      if (data['danh_sach'] is List) {
        return data['danh_sach'];
      }

      if (data['data'] is List) {
        return data['data'];
      }
    }
  }

  return [];
}

static int _laySoChuaDocTuBody(dynamic body) {
    if (body is Map) {
      if (body['so_chua_doc'] != null) {
        return int.tryParse(body['so_chua_doc'].toString()) ?? 0;
      }

      if (body['chua_doc'] != null) {
        return int.tryParse(body['chua_doc'].toString()) ?? 0;
      }

      if (body['unread_count'] != null) {
        return int.tryParse(body['unread_count'].toString()) ?? 0;
      }

      if (body['data'] is Map) {
        final data = body['data'];

        if (data['so_chua_doc'] != null) {
          return int.tryParse(data['so_chua_doc'].toString()) ?? 0;
        }

        if (data['chua_doc'] != null) {
          return int.tryParse(data['chua_doc'].toString()) ?? 0;
        }

        if (data['unread_count'] != null) {
          return int.tryParse(data['unread_count'].toString()) ?? 0;
        }
      }
    }

    return 0;
  }

  static Future<List<ThongBao>> layDanhSachThongBao() async {
    final token = await _layToken();

    if (token.isEmpty) {
      throw Exception('Chưa có token đăng nhập');
    }

    final url = Uri.parse(
      DuongDanApi.noiApi(DuongDanApi.danhSachThongBao),
    );

    final response = await http
        .get(
          url,
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));
        print('THONG BAO RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Lỗi ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final list = _layList(body);

    return list
        .whereType<Map>()
        .map((e) => ThongBao.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> danhDauDaDoc(int id) async {
      final token = await _layToken();

      if (token.isEmpty) {
        throw Exception('Chưa có token đăng nhập');
      }

      final url = Uri.parse(
        DuongDanApi.noiApi(DuongDanApi.docThongBao(id)),
      );

      final response = await http
          .patch(
            url,
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    }

    // đếm thông báo chưa đọc
    static Future<int> demThongBaoChuaDoc() async {
    final token = await _layToken();

    if (token.isEmpty) {
      return 0;
    }

    final url = Uri.parse(
      DuongDanApi.noiApi(DuongDanApi.soThongBaoChuaDoc),
    );

    final response = await http
        .get(
          url,
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Lỗi ${response.statusCode}: ${response.body}');
    }

    return _laySoChuaDocTuBody(jsonDecode(response.body));
  }

  //Đánh đáu tất cả đã đọc
  static Future<void> danhDauTatCaDaDoc() async {
    final token = await _layToken();

    if (token.isEmpty) {
      throw Exception('Chưa có token đăng nhập');
    }

    final url = Uri.parse(
      DuongDanApi.noiApi(DuongDanApi.docTatCaThongBao),
    );

    final response = await http
        .patch(
          url,
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Lỗi ${response.statusCode}: ${response.body}');
    }
  }

}