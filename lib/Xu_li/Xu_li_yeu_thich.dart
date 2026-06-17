import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Server/Goi_api.dart';
import '../Xu_li_api/Yeu_thich_api.dart';

class XuLiYeuThich extends ChangeNotifier {
  final Set<int> danhSachCoSoYeuThich = {};

  bool daTaiYeuThich = false;

  bool kiemTraYeuThich(int coSoId) {
    return danhSachCoSoYeuThich.contains(coSoId);
  }

  Future<String> _layTokenDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      GoiApi.token = token;
    }

    return token;
  }

  Future<void> taiYeuThichDaLuu() async {
    final prefs = await SharedPreferences.getInstance();

    final danhSachIdString = prefs.getStringList('co_so_yeu_thich') ?? [];

    danhSachCoSoYeuThich.clear();

    for (final idString in danhSachIdString) {
      final id = int.tryParse(idString);

      if (id != null) {
        danhSachCoSoYeuThich.add(id);
      }
    }

    try {
      final token = await _layTokenDaLuu();

      if (token.isNotEmpty) {
        final danhSachServer = await YeuThichApi().layDanhSachYeuThich();

        danhSachCoSoYeuThich
          ..clear()
          ..addAll(danhSachServer);

        await luuYeuThich();
      }
    } catch (_) {
      // Nếu server chưa bật API yêu thích thì vẫn dùng danh sách đã lưu local.
    }

    daTaiYeuThich = true;
    notifyListeners();
  }

  Future<void> luuYeuThich() async {
    final prefs = await SharedPreferences.getInstance();

    final danhSachIdString = danhSachCoSoYeuThich.map((id) {
      return id.toString();
    }).toList();

    await prefs.setStringList(
      'co_so_yeu_thich',
      danhSachIdString,
    );
  }

  Future<void> doiYeuThich(int coSoId) async {
    final daYeuThich = danhSachCoSoYeuThich.contains(coSoId);

    if (daYeuThich) {
      danhSachCoSoYeuThich.remove(coSoId);
    } else {
      danhSachCoSoYeuThich.add(coSoId);
    }

    await luuYeuThich();
    notifyListeners();

    try {
      final token = await _layTokenDaLuu();

      if (token.isNotEmpty) {
        if (daYeuThich) {
          await YeuThichApi().xoaYeuThich(coSoId);
        } else {
          await YeuThichApi().themYeuThich(coSoId);
        }
      }
    } catch (_) {
      // Giữ trạng thái local để app không bị văng khi API yêu thích lỗi.
    }
  }

  Future<void> xoaTatCaYeuThich() async {
    danhSachCoSoYeuThich.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('co_so_yeu_thich');

    notifyListeners();
  }
}
