import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Mau_du_lieu/Nguoi_dung.dart';
import '../Server/Goi_api.dart';
import '../Xu_li_api/Tai_khoan_api.dart';

class XuLiTaiKhoan extends ChangeNotifier {
  bool daDangNhap = false;
  bool dangTai = false;
  bool daKiemTraDangNhap = false;

  String? token;
  String? thongBaoLoi;
  String? thongBaoThanhCong;

  NguoiDung? nguoiDung;

  Future<bool> dangNhap({
    required String taiKhoan,
    required String matKhau,
  }) async {
    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().dangNhap(
        taiKhoan: taiKhoan,
        matKhau: matKhau,
      );

      final tokenNhanDuoc = ketQua['token']?.toString() ?? '';
      final userJson = ketQua['user'];

      if (tokenNhanDuoc.isEmpty) {
        throw Exception('API đăng nhập chưa trả về token');
      }

      if (userJson == null) {
        throw Exception('API đăng nhập chưa trả về user');
      }

      token = tokenNhanDuoc;
      GoiApi.token = tokenNhanDuoc;

      try {
        final thongTinMoi = await TaiKhoanApi().layThongTinTaiKhoan(
          token: tokenNhanDuoc,
        );
        final userMoi = thongTinMoi['user'];

        nguoiDung = NguoiDung.fromJson(
          Map<String, dynamic>.from(userMoi),
        );
      } catch (_) {
        nguoiDung = NguoiDung.fromJson(
          Map<String, dynamic>.from(userJson),
        );
      }

      daDangNhap = true;
      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Đăng nhập thành công';

      await luuDangNhap();

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      daDangNhap = false;
      token = null;
      GoiApi.token = null;
      nguoiDung = null;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');

      await xoaDangNhap();

      notifyListeners();

      return false;
    }
  }

  Future<bool> dangKy({
    required String hoTen,
    required String email,
    required String matKhau,
    required String soDienThoai,
  }) async {
    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().dangKy(
        hoTen: hoTen,
        email: email,
        matKhau: matKhau,
        soDienThoai: soDienThoai,
      );

      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Đăng ký thành công';

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<bool> quenMatKhau({
    String? email,
    String? taiKhoan,
  }) async {
    final emailGuiDi = email ?? taiKhoan ?? '';

    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().quenMatKhau(
        email: emailGuiDi,
      );

      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Đã gửi mã OTP về email';

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<bool> xacThucOtp({
    String? email,
    String? taiKhoan,
    String? maOtp,
    String? ma_otp,
    String? otp,
  }) async {
    final emailGuiDi = email ?? taiKhoan ?? '';
    final otpGuiDi = maOtp ?? ma_otp ?? otp ?? '';

    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().xacThucOtp(
        email: emailGuiDi,
        maOtp: otpGuiDi,
      );

      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Xác thực OTP thành công';

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<bool> datLaiMatKhau({
    String? email,
    String? taiKhoan,
    String? matKhauMoi,
    String? xacNhanMatKhau,
    String? mat_khau_moi,
    String? xac_nhan_mat_khau,
  }) async {
    final emailGuiDi = email ?? taiKhoan ?? '';
    final mkMoi = matKhauMoi ?? mat_khau_moi ?? '';
    final xacNhan = xacNhanMatKhau ?? xac_nhan_mat_khau ?? mkMoi;

    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().datLaiMatKhau(
        email: emailGuiDi,
        matKhauMoi: mkMoi,
        xacNhanMatKhau: xacNhan,
      );

      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Đặt lại mật khẩu thành công';

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  String? chuyenGioiTinhSangApi(String? gioiTinh) {
    if (gioiTinh == null || gioiTinh.trim().isEmpty) return null;

    final text = gioiTinh.trim().toLowerCase();

    if (text == 'nam' || text == 'male' || text == '1') return 'male';
    if (text == 'nữ' || text == 'nu' || text == 'female' || text == '0' || text == '2') {
      return 'female';
    }
    if (text == 'khác' || text == 'khac' || text == 'other' || text == '3') {
      return 'other';
    }

    return gioiTinh.trim();
  }

  Future<String> layTokenDangNhap() async {
    if (token != null && token!.isNotEmpty) {
      GoiApi.token = token;
      return token!;
    }

    final prefs = await SharedPreferences.getInstance();
    final tokenDaLuu = prefs.getString('token') ?? '';

    if (tokenDaLuu.isNotEmpty) {
      token = tokenDaLuu;
      GoiApi.token = tokenDaLuu;
      return tokenDaLuu;
    }

    return '';
  }

  Future<bool> capNhatThongTin({
    required String hoTen,
    required String soDienThoai,
    String? gioiTinh,
    String? ngaySinh,
    String? avatar,
  }) async {
    final tokenHienTai = await layTokenDangNhap();

    if (tokenHienTai.isEmpty) {
      thongBaoLoi = 'Bạn chưa đăng nhập';
      notifyListeners();
      return false;
    }

    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().capNhatTaiKhoan(
        token: tokenHienTai,
        hoTen: hoTen,
        soDienThoai: soDienThoai,
        gioiTinh: chuyenGioiTinhSangApi(gioiTinh),
        ngaySinh: ngaySinh ?? '',
        avatar: avatar ?? '',
      );

      final userJson = ketQua['user'];

      if (userJson is Map) {
        nguoiDung = NguoiDung.fromJson(
          Map<String, dynamic>.from(userJson),
        );
      } else {
        nguoiDung = (nguoiDung ?? NguoiDung()).copyWith(
          hoTen: hoTen,
          soDienThoai: soDienThoai,
          gioiTinh: gioiTinh ?? nguoiDung?.gioiTinh ?? '',
          ngaySinh: ngaySinh ?? nguoiDung?.ngaySinh ?? '',
          avatar: avatar ?? nguoiDung?.avatar ?? '',
        );
      }

      daDangNhap = true;
      token = tokenHienTai;

      await luuDangNhap();

      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Cập nhật thông tin thành công';

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }


  Future<bool> doiMatKhau({
    required String matKhauCu,
    required String matKhauMoi,
    required String xacNhanMatKhauMoi,
  }) async {
    final tokenHienTai = await layTokenDangNhap();

    if (tokenHienTai.isEmpty) {
      thongBaoLoi = 'Bạn chưa đăng nhập';
      notifyListeners();
      return false;
    }

    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await TaiKhoanApi().doiMatKhau(
        matKhauCu: matKhauCu,
        matKhauMoi: matKhauMoi,
        xacNhanMatKhauMoi: xacNhanMatKhauMoi,
      );

      thongBaoThanhCong =
          ketQua['message']?.toString() ?? 'Đổi mật khẩu thành công';

      dangTai = false;
      notifyListeners();

      return true;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    }
  }

  Future<void> luuDangNhap() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('da_dang_nhap', daDangNhap);
    await prefs.setString('token', token ?? '');

    if (nguoiDung != null) {
      await prefs.setString(
        'nguoi_dung',
        jsonEncode(nguoiDung!.toJson()),
      );
    }
  }

  Future<void> taiDangNhapDaLuu() async {
    dangTai = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    final daLuuDangNhap = prefs.getBool('da_dang_nhap') ?? false;
    final tokenDaLuu = prefs.getString('token') ?? '';
    final nguoiDungDaLuu = prefs.getString('nguoi_dung') ?? '';

    if (daLuuDangNhap == true &&
        tokenDaLuu.isNotEmpty &&
        nguoiDungDaLuu.isNotEmpty) {
      try {
        final userMap = Map<String, dynamic>.from(
          jsonDecode(nguoiDungDaLuu),
        );

        token = tokenDaLuu;
        GoiApi.token = tokenDaLuu;
        nguoiDung = NguoiDung.fromJson(userMap);
        daDangNhap = true;

        try {
          final thongTinMoi = await TaiKhoanApi().layThongTinTaiKhoan(
            token: tokenDaLuu,
          );
          final userMoi = thongTinMoi['user'];

          if (userMoi is Map) {
            nguoiDung = NguoiDung.fromJson(
              Map<String, dynamic>.from(userMoi),
            );
            await luuDangNhap();
          }
        } catch (_) {
          // Nếu mạng chậm hoặc Render chưa thức dậy thì vẫn dùng dữ liệu đã lưu.
        }
      } catch (e) {
        token = null;
        GoiApi.token = null;
        nguoiDung = null;
        daDangNhap = false;

        await xoaDangNhap();
      }
    } else {
      token = null;
      GoiApi.token = null;
      nguoiDung = null;
      daDangNhap = false;
    }

    dangTai = false;
    daKiemTraDangNhap = true;
    notifyListeners();
  }

  Future<void> dangXuat() async {
    token = null;
    GoiApi.token = null;
    nguoiDung = null;
    daDangNhap = false;
    thongBaoLoi = null;
    thongBaoThanhCong = null;

    await xoaDangNhap();

    notifyListeners();
  }

  Future<void> xoaDangNhap() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('da_dang_nhap');
    await prefs.remove('token');
    await prefs.remove('nguoi_dung');
  }
}