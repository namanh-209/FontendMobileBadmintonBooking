import 'package:flutter/material.dart';

import '../Mau_du_lieu/San.dart';
import '../Xu_li_api/San_api.dart';

class SanXuLy extends ChangeNotifier {
  final SanApi _sanApi = SanApi();

  bool dangTai = false;
  String? thongBaoLoi;
  List<San> danhSachSan = [];

  Future<void> layDanhSachSan() async {
    dangTai = true;
    thongBaoLoi = null;
    notifyListeners();

    try {
      danhSachSan = await _sanApi.layDanhSachSan();

      if (danhSachSan.isEmpty) {
        thongBaoLoi = 'Chưa có dữ liệu sân hoặc API chưa trả dữ liệu';
      }
    } catch (e) {
      danhSachSan = [];
      thongBaoLoi = 'Không lấy được danh sách sân';
    } finally {
      dangTai = false;
      notifyListeners();
    }
  }
}