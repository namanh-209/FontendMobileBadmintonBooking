import 'package:flutter/material.dart';

import '../Mau_du_lieu/Dat_san.dart';
import '../Xu_li_api/Thanh_toan_api.dart';

class XuLiThanhToan extends ChangeNotifier {
  final ThanhToanApi _api = ThanhToanApi();

  bool dangTai = false;
  String? thongBaoLoi;
  dynamic ketQuaThanhToan;

  Future<bool> taoThanhToanChuyenKhoan(DatSan datSan) async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      final thongTin = _api.layThongTinChuyenKhoan(datSan);

      ketQuaThanhToan = await _api.taoThanhToan(
        datSanId: datSan.id,
        soTien: thongTin.soTien,
        loaiThanhToan: 1,
        phuongThuc: 'CHUYEN_KHOAN',
      );

      dangTai = false;
      notifyListeners();
      return true;
    } catch (e) {
      thongBaoLoi = '$e';
      dangTai = false;
      notifyListeners();
      return false;
    }
  }
}
