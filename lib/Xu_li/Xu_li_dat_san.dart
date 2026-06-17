import 'package:flutter/material.dart';

import '../Mau_du_lieu/Dat_san.dart';
import '../Xu_li_api/Dat_san_api.dart';

class XuLiDatSan extends ChangeNotifier {
  bool dangTai = false;
  String? thongBaoLoi;
  String? thongBaoThanhCong;

  List<DatSan> lichSuDatSan = [];

  Future<Map<String, dynamic>?> giuChoTamThoi({
    required int coSoId,
    required String ngay,
    required List<Map<String, dynamic>> slots,
    String ghiChu = '',
  }) async {
    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await DatSanApi().giuChoTamThoi(
        coSoId: coSoId,
        ngay: ngay,
        slots: slots,
        ghiChu: ghiChu,
      );

      thongBaoThanhCong = ketQua['message']?.toString() ?? 'Giữ chỗ thành công';
      dangTai = false;
      notifyListeners();
      return ketQua;
    } catch (e) {
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      dangTai = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> layLichSuDatSan() async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      lichSuDatSan = await DatSanApi().layLichSuDatSanCuaToi();
      dangTai = false;
      notifyListeners();
    } catch (e) {
      lichSuDatSan = [];
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      dangTai = false;
      notifyListeners();
    }
  }

  Future<bool> huyGiuCho(dynamic datSanId) async {
    dangTai = true;
    thongBaoLoi = null;
    thongBaoThanhCong = null;
    notifyListeners();

    try {
      final ketQua = await DatSanApi().huyGiuCho(datSanId);
      thongBaoThanhCong = ketQua['message']?.toString() ?? 'Đã hủy giữ chỗ';
      await layLichSuDatSan();
      dangTai = false;
      notifyListeners();
      return true;
    } catch (e) {
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      dangTai = false;
      notifyListeners();
      return false;
    }
  }
}
