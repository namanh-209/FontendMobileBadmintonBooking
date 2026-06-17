import 'package:flutter/foundation.dart';

class DuongDanApi {
  static const String cong = '3000';

  // Android Emulator dùng 10.0.2.2
  // Điện thoại thật thì đổi thành IPv4 máy bạn, ví dụ: 192.168.1.8
  static const String ipMayTinh = '10.0.2.2';

  static String get gocServer {
    final host = kIsWeb ? 'localhost' : ipMayTinh;
    return 'http://$host:$cong';
  }

  static String get goc {
    return '$gocServer/api';
  }

  static String linkAnh(String url) {
    final value = url.trim();

    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '$gocServer$value';
    }

    return '$gocServer/$value';
  }

  static String taoQuery(Map<String, dynamic> params) {
    final query = <String, String>{};

    params.forEach((key, value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isEmpty) return;
      query[key] = text;
    });

    if (query.isEmpty) return '';
    return '?${Uri(queryParameters: query).query}';
  }

  // Auth
  static const String dangKy = '/auth/register';
  static const String dangNhap = '/auth/login';
  static const String quenMatKhau = '/auth/quen-mat-khau';
  static const String xacThucOtp = '/auth/xac-thuc-otp';
  static const String datLaiMatKhau = '/auth/dat-lai-mat-khau';

  // User
  static const String hoSo = '/user/me';
  static const String capNhatHoSo = '/user/profile';
  static const String doiMatKhau = '/user/change-password';

  // Cơ sở / sân
  static const String danhSachCoSo = '/co-so';

  static String danhSachCoSoLoc({
    String? tuKhoa,
    String? tinhThanh,
    String? phuongXa,
    String? loaiSan,
    num? giaTu,
    num? giaDen,
    String? ngay,
    String? gio,
    String? sapXep,
  }) {
    return '$danhSachCoSo${taoQuery({
      'tu_khoa': tuKhoa,
      'tinh_thanh': tinhThanh,
      'phuong_xa': phuongXa,
      'loai_san': loaiSan,
      'gia_tu': giaTu,
      'gia_den': giaDen,
      'ngay': ngay,
      'gio': gio,
      'sap_xep': sapXep,
    })}';
  }

  static String chiTietCoSo(dynamic id) {
    return '/co-so/$id';
  }

  static String danhSachSanTheoCoSo(dynamic coSoId) {
    return '/san?co_so_id=$coSoId';
  }

  static String lichTheoCoSo(dynamic coSoId, {String? ngay}) {
    if (ngay == null || ngay.isEmpty) return '/dat-san/lich?co_so_id=$coSoId';
    return '/dat-san/lich?co_so_id=$coSoId&ngay=$ngay';
  }

  static const String danhSachSan = '/san';

  static String chiTietSan(dynamic id) {
    return '/san/$id';
  }

  // Backend hiện tại xem lịch công khai theo cơ sở, không có route lịch công khai theo từng sân.
  static String lichSan(dynamic sanId, {String? ngay}) {
    if (ngay == null) return '/san/$sanId/lich';
    return '/san/$sanId/lich?ngay=$ngay';
  }

  // Đặt sân
  static const String giuChoDatSan = '/dat-san/giu-cho';
  static const String lichSuDatSanCuaToi = '/dat-san/lich-su-cua-toi';

  static String huyGiuCho(dynamic datSanId) {
    return '/dat-san/$datSanId/huy-giu-cho';
  }

  // Thanh toán
  static const String taoUrlThanhToanVnpay = '/thanh-toan/vnpay/tao-url';
  static const String vnpayReturn = '/thanh-toan/vnpay/return';

  // Yêu thích
  static const String danhSachYeuThich = '/yeu-thich';

  static String themYeuThich(dynamic coSoId) {
    return '/yeu-thich/$coSoId';
  }

  static String xoaYeuThich(dynamic coSoId) {
    return '/yeu-thich/$coSoId';
  }

  static String kiemTraYeuThich(dynamic coSoId) {
    return '/yeu-thich/check/$coSoId';
  }
}
