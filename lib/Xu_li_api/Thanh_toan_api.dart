import 'dart:convert';

import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';

class ThongTinChuyenKhoan {
  final String nganHang;
  final String soTaiKhoan;
  final String tenTaiKhoan;
  final double soTien;
  final String noiDung;
  final String qrUrl;

  ThongTinChuyenKhoan({
    required this.nganHang,
    required this.soTaiKhoan,
    required this.tenTaiKhoan,
    required this.soTien,
    required this.noiDung,
    required this.qrUrl,
  });
}

class ThanhToanApi {
  final GoiApi _api = GoiApi();

  double soTienCanThanhToan(DatSan datSan, {String loaiThanhToan = 'deposit'}) {
    final thanhTien = datSan.thanhTien > 0 ? datSan.thanhTien : datSan.tongTien;

    if (loaiThanhToan == 'full') return thanhTien;
    if (loaiThanhToan == 'remaining') return datSan.conLai;
    if (datSan.tienCoc > 0) return datSan.tienCoc;

    return thanhTien;
  }

  // Giữ lại hàm này để các màn cũ không bị lỗi biên dịch.
  ThongTinChuyenKhoan layThongTinChuyenKhoan(DatSan datSan) {
    final soTien = soTienCanThanhToan(datSan);
    final noiDung = 'DAT SAN ${datSan.id}';

    return ThongTinChuyenKhoan(
      nganHang: 'VNPay',
      soTaiKhoan: 'Thanh toán qua cổng VNPay',
      tenTaiKhoan: 'BADMINTON BOOKING',
      soTien: soTien,
      noiDung: noiDung,
      qrUrl: '',
    );
  }

  Future<Map<String, dynamic>> taoUrlVnpay({
    required int datSanId,
    String loaiThanhToan = 'deposit',
  }) async {
    final data = await _api.post(
      DuongDanApi.taoUrlThanhToanVnpay,
      body: {
        'dat_san_id': datSanId,
        'loai_thanh_toan': loaiThanhToan,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<String> taoLinkThanhToanVnpay({
    required int datSanId,
    String loaiThanhToan = 'deposit',
  }) async {
    final data = await taoUrlVnpay(
      datSanId: datSanId,
      loaiThanhToan: loaiThanhToan,
    );

    final url = (data['payment_url'] ?? data['url'] ?? data['data']?['payment_url'] ?? '').toString();
    if (url.isEmpty) throw LoiApi('API chưa trả payment_url VNPay');
    return url;
  }

  Future<Map<String, dynamic>> taoUrlThanhToanCoc(int datSanId) {
    return taoUrlVnpay(datSanId: datSanId, loaiThanhToan: 'deposit');
  }

  Future<Map<String, dynamic>> taoUrlThanhToanTatCa(int datSanId) {
    return taoUrlVnpay(datSanId: datSanId, loaiThanhToan: 'full');
  }

  Future<Map<String, dynamic>> taoUrlThanhToanConLai(int datSanId) {
    return taoUrlVnpay(datSanId: datSanId, loaiThanhToan: 'remaining');
  }

  // Giữ lại hàm cũ để XuLiThanhToan không lỗi. Backend web thật dùng VNPay bên trên.
  Future<dynamic> taoThanhToan({
    required int datSanId,
    required double soTien,
    int loaiThanhToan = 1,
    String phuongThuc = 'VNPAY',
  }) async {
    final loai = loaiThanhToan == 2 || phuongThuc.toLowerCase().contains('full') ? 'full' : 'deposit';
    return taoUrlVnpay(datSanId: datSanId, loaiThanhToan: loai);
  }

  String prettyJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return '$data';
    }
  }
}
