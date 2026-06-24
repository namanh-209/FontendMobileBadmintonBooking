import 'dart:io';

import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Nguoi_dung.dart';
import '../Server/Goi_api.dart';

class TaiKhoanApi {
  final GoiApi _api = GoiApi();

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Map<String, dynamic> _chuanHoaKetQua(dynamic data) {
    final map = _asMap(data);
    final user = map['user'] ?? map['data'] ?? map['nguoiDung'] ?? map['nguoi_dung'];

    if (user is Map && map['user'] == null) {
      return {
        ...map,
        'user': Map<String, dynamic>.from(user),
      };
    }

    return map;
  }

  String _gioiTinhGiongWeb(dynamic value) {
    final text = value?.toString().trim().toLowerCase() ?? '';

    if (text.isEmpty) return 'male';
    if (text == 'nam' || text == 'male' || text == '1') return 'male';
    if (text == 'nữ' || text == 'nu' || text == 'female' || text == '0' || text == '2') {
      return 'female';
    }
    if (text == 'khác' || text == 'khac' || text == 'other' || text == '3') {
      return 'other';
    }

    return text;
  }

  bool _laLinkOnline(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('/uploads/') ||
        value.startsWith('uploads/') ||
        value.startsWith('res.cloudinary.com/');
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

    final data = await _api.post(
      DuongDanApi.dangKy,
      body: {
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

    final data = await _api.post(
      DuongDanApi.dangNhap,
      body: {
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
    final data = await _api.post(
      DuongDanApi.quenMatKhau,
      body: {'email': email},
    );

    return _chuanHoaKetQua(data);
  }

  Future<Map<String, dynamic>> xacThucOtp({
    required String email,
    String? maOtp,
    String? otp,
  }) async {
    final ma = maOtp ?? otp ?? '';

    final data = await _api.post(
      DuongDanApi.xacThucOtp,
      body: {
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
    final data = await _api.post(
      DuongDanApi.datLaiMatKhau,
      body: {
        'email': email,
        'mat_khau_moi': matKhauMoi,
        'xac_nhan_mat_khau': xacNhanMatKhau ?? matKhauMoi,
      },
    );

    return _chuanHoaKetQua(data);
  }

  Future<Map<String, dynamic>> layThongTinTaiKhoan({String? token}) async {
    if (token != null && token.isNotEmpty) GoiApi.token = token;

    final data = await _api.get(DuongDanApi.hoSo);
    final map = _chuanHoaKetQua(data);
    final user = map['user'] ?? map['data'] ?? map;

    return {
      ...map,
      'user': user is Map ? Map<String, dynamic>.from(user) : NguoiDung().toJson(),
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
    if (token != null && token.isNotEmpty) GoiApi.token = token;

    final ten = hoTen ?? username ?? '';
    final avatarText = avatar?.trim() ?? '';

    final laFileAvatar = avatarText.isNotEmpty &&
        !_laLinkOnline(avatarText) &&
        File(avatarText).existsSync();

    final fields = <String, String>{
      'ho_ten': ten,
      'so_dien_thoai': soDienThoai ?? '',
      'ngay_sinh': ngaySinh?.trim() ?? '',
      'gioi_tinh': _gioiTinhGiongWeb(gioiTinh),
    };

    final files = <String, String>{};
    if (laFileAvatar) {
      files['avatar'] = avatarText;
    }

    final data = await _api.putMultipart(
      DuongDanApi.capNhatHoSo,
      fields: fields,
      files: files,
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
          if (!laFileAvatar && avatarText.isNotEmpty) 'avatar': avatarText,
        },
      };
    }
  }

  Future<Map<String, dynamic>> doiMatKhau({
    required String matKhauCu,
    required String matKhauMoi,
    required String xacNhanMatKhauMoi,
  }) async {
    final data = await _api.put(
      DuongDanApi.doiMatKhau,
      body: {
        'mat_khau_cu': matKhauCu,
        'mat_khau_moi': matKhauMoi,
        'xac_nhan_mat_khau_moi': xacNhanMatKhauMoi,
      },
    );

    return _chuanHoaKetQua(data);
  }
}
