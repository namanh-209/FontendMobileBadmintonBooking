import 'dart:io';

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
    if (token != null && token.isNotEmpty) GoiApi.token = token;

    final data = await GoiApi.get(DuongDanApi.hoSo);
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
        ? await GoiApi.putMultipart(
            DuongDanApi.capNhatHoSo,
            fields: fields,
            files: {
              'avatar': avatarText,
            },
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
