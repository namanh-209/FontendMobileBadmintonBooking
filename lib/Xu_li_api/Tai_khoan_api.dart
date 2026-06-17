import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Nguoi_dung.dart';
import '../Server/Goi_api.dart';

class TaiKhoanApi {
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Map<String, dynamic> _chuanHoaKetQua(dynamic data) {
    final map = _asMap(data);
    final user = map['user'] ?? map['data'] ?? map['nguoiDung'];

    if (user is Map && map['user'] == null) {
      return {
        ...map,
        'user': Map<String, dynamic>.from(user),
      };
    }

    return map;
  }

  Uri _uri(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }

    return Uri.parse('${DuongDanApi.goc}$path');
  }

  dynamic _decode(String body) {
    final value = body.trim();
    if (value.isEmpty) return null;

    try {
      return jsonDecode(value);
    } catch (_) {
      return value;
    }
  }

  dynamic _xuLyResponse(http.Response res) {
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

  MediaType _layKieuAnh(String duongDan) {
    final duoiFile = duongDan.split('.').last.toLowerCase();

    if (duoiFile == 'png') {
      return MediaType('image', 'png');
    }

    if (duoiFile == 'webp') {
      return MediaType('image', 'webp');
    }

    if (duoiFile == 'jpg' || duoiFile == 'jpeg') {
      return MediaType('image', 'jpeg');
    }

    // ImagePicker trên Android đôi khi trả path hơi lạ,
    // ép mặc định thành jpeg để backend multer hiểu đây là ảnh.
    return MediaType('image', 'jpeg');
  }

  String _layTenFileAnh(String duongDan) {
    final tenGoc = duongDan.split('/').last.split('\\').last;
    final tenThuong = tenGoc.toLowerCase();

    if (tenThuong.endsWith('.jpg') ||
        tenThuong.endsWith('.jpeg') ||
        tenThuong.endsWith('.png') ||
        tenThuong.endsWith('.webp')) {
      return tenGoc;
    }

    return 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Future<dynamic> _putMultipartCapNhatHoSo({
    required Map<String, String> fields,
    required String avatarPath,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      _uri(DuongDanApi.capNhatHoSo),
    );

    request.headers['Accept'] = 'application/json';

    if (GoiApi.token != null && GoiApi.token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer ${GoiApi.token}';
    }

    request.fields.addAll(fields);

    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        avatarPath,
        filename: _layTenFileAnh(avatarPath),
        contentType: _layKieuAnh(avatarPath),
      ),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    return _xuLyResponse(res);
  }

  Future<Map<String, dynamic>> dangKy({
    String? hoTen,
    String? username,
    required String email,
    String? matKhau,
    String? password,
    String? soDienThoai,
    String? gioiTinh,
  }) async {
    final ten = hoTen ?? username ?? '';
    final mk = matKhau ?? password ?? '';

    final data = await GoiApi.post(
      DuongDanApi.dangKy,
      {
        'ho_ten': ten,
        'email': email,
        'mat_khau': mk,
        'so_dien_thoai': soDienThoai,
      },
    );

    return _chuanHoaKetQua(data);
  }

  Future<Map<String, dynamic>> dangNhap({
    String? taiKhoan,
    String? emailHoacUsername,
    String? email,
    String? username,
    String? matKhau,
    String? password,
  }) async {
    final tk = taiKhoan ?? emailHoacUsername ?? email ?? username ?? '';
    final mk = matKhau ?? password ?? '';

    final data = await GoiApi.post(
      DuongDanApi.dangNhap,
      {
        'tai_khoan': tk,
        'mat_khau': mk,
      },
    );

    final map = _chuanHoaKetQua(data);
    final token = map['token'] ?? map['accessToken'] ?? map['access_token'];

    if (token != null) {
      GoiApi.token = token.toString();
    }

    return map;
  }

  Future<Map<String, dynamic>> quenMatKhau({
    required String email,
  }) async {
    final data = await GoiApi.post(
      DuongDanApi.quenMatKhau,
      {
        'email': email,
      },
    );

    return _chuanHoaKetQua(data);
  }

  Future<Map<String, dynamic>> xacThucOtp({
    required String email,
    String? maOtp,
    String? otp,
  }) async {
    final ma = maOtp ?? otp ?? '';

    final data = await GoiApi.post(
      DuongDanApi.xacThucOtp,
      {
        'email': email,
        'ma_otp': ma,
      },
    );

    return _chuanHoaKetQua(data);
  }

  Future<Map<String, dynamic>> datLaiMatKhau({
    required String email,
    String? otp,
    String? maOtp,
    required String matKhauMoi,
    String? xacNhanMatKhau,
  }) async {
    final data = await GoiApi.post(
      DuongDanApi.datLaiMatKhau,
      {
        'email': email,
        'mat_khau_moi': matKhauMoi,
        'xac_nhan_mat_khau': xacNhanMatKhau ?? matKhauMoi,
      },
    );

    return _chuanHoaKetQua(data);
  }

  Future<Map<String, dynamic>> layThongTinTaiKhoan({String? token}) async {
    if (token != null && token.isNotEmpty) {
      GoiApi.token = token;
    }

    final data = await GoiApi.get(DuongDanApi.hoSo);
    final map = _chuanHoaKetQua(data);
    final user = map['user'] ?? map['data'] ?? map;

    return {
      ...map,
      'user': user is Map
          ? Map<String, dynamic>.from(user)
          : NguoiDung().toJson(),
    };
  }

  Future<Map<String, dynamic>> capNhatTaiKhoan({
    String? token,
    String? hoTen,
    String? username,
    String? email,
    String? soDienThoai,
    dynamic gioiTinh,
    String? ngaySinh,
    String? avatar,
  }) async {
    if (token != null && token.isNotEmpty) {
      GoiApi.token = token;
    }

    final ten = hoTen ?? username ?? '';
    final avatarText = avatar?.trim() ?? '';

    final laFileAvatar = avatarText.isNotEmpty &&
        !avatarText.startsWith('http://') &&
        !avatarText.startsWith('https://') &&
        !avatarText.startsWith('/uploads/') &&
        !avatarText.startsWith('uploads/') &&
        File(avatarText).existsSync();

    final fields = <String, String>{
      'ho_ten': ten,
      'so_dien_thoai': soDienThoai ?? '',
      if (gioiTinh != null) 'gioi_tinh': gioiTinh.toString(),
      if (ngaySinh != null && ngaySinh.isNotEmpty) 'ngay_sinh': ngaySinh,
    };

    final data = laFileAvatar
        ? await _putMultipartCapNhatHoSo(
            fields: fields,
            avatarPath: avatarText,
          )
        : await GoiApi.put(
            DuongDanApi.capNhatHoSo,
            fields,
          );

    final map = _chuanHoaKetQua(data);

    try {
      final profile = await layThongTinTaiKhoan(token: token);
      return {
        ...map,
        'user': profile['user'],
      };
    } catch (_) {
      return {
        ...map,
        'user': {
          ...fields,
          'email': email,
          if (avatarText.isNotEmpty) 'avatar': avatarText,
        },
      };
    }
  }

  Future<Map<String, dynamic>> doiMatKhau({
    required String matKhauCu,
    required String matKhauMoi,
    required String xacNhanMatKhauMoi,
  }) async {
    final data = await GoiApi.put(
      DuongDanApi.doiMatKhau,
      {
        'mat_khau_cu': matKhauCu,
        'mat_khau_moi': matKhauMoi,
        'xac_nhan_mat_khau_moi': xacNhanMatKhauMoi,
      },
    );

    return _chuanHoaKetQua(data);
  }
}