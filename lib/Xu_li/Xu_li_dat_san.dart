import 'package:flutter/material.dart';

import '../Mau_du_lieu/Dat_san.dart';
import '../Xu_li_api/Dat_san_api.dart';

class XuLiDatSan extends ChangeNotifier {
  final DatSanApi _api = DatSanApi();

  List<DatSan> danhSachDatSan = [];
  bool dangTai = false;
  String? thongBaoLoi;

  Future<void> layLichDatCuaToi() async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      danhSachDatSan = await _api.layLichDatCuaToi();
    } catch (e) {
      thongBaoLoi = '$e';
    }

    dangTai = false;
    notifyListeners();
  }

  Future<DatSan?> taoDatSan({
    required int coSoId,
    required List<Map<String, dynamic>> chiTiet,
    String ghiChu = '',
  }) async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      final datSan = await _api.taoDatSan(
        coSoId: coSoId,
        chiTiet: chiTiet,
        ghiChu: ghiChu,
      );

      danhSachDatSan.insert(0, datSan);
      dangTai = false;
      notifyListeners();
      return datSan;
    } catch (e) {
      thongBaoLoi = '$e';
      dangTai = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> huyDatSan({
    required int datSanId,
    required String lyDoHuy,
  }) async {
    try {
      await _api.huyDatSan(datSanId: datSanId, lyDoHuy: lyDoHuy);
      await layLichDatCuaToi();
      return true;
    } catch (e) {
      thongBaoLoi = '$e';
      notifyListeners();
      return false;
    }
  }
}
