import 'package:flutter/material.dart';

import '../Mau_du_lieu/Co_so.dart';
import '../Xu_li_api/Co_so_api.dart';

class XuLiCoSo extends ChangeNotifier {
  bool dangTai = false;
  String? thongBaoLoi;

  List<CoSo> danhSachCoSo = [];

  Future<void> layDanhSachCoSo({
    String? tuKhoa,
    String? tinhThanh,
    String? phuongXa,
    String? loaiSan,
    num? giaTu,
    num? giaDen,
    String? ngay,
    String? gio,
    String? sapXep,
  }) async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      danhSachCoSo = await CoSoApi().layDanhSachCoSo(
        tuKhoa: tuKhoa,
        tinhThanh: tinhThanh,
        phuongXa: phuongXa,
        loaiSan: loaiSan,
        giaTu: giaTu,
        giaDen: giaDen,
        ngay: ngay,
        gio: gio,
        sapXep: sapXep,
      );

      dangTai = false;
      notifyListeners();
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<CoSo?> layChiTietCoSo(int id) async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      final coSo = await CoSoApi().layChiTietCoSo(id);

      dangTai = false;
      notifyListeners();

      return coSo;
    } catch (e) {
      dangTai = false;
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return null;
    }
  }
}
