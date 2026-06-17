import 'package:flutter/material.dart';

import '../Xu_li_api/Thanh_toan_api.dart';

class XuLiThanhToan extends ChangeNotifier {
  bool dangTai = false;
  String? thongBaoLoi;
  String? paymentUrl;
  Map<String, dynamic>? ketQuaThanhToan;

  Future<String> taoUrlThanhToanVnpay({
    required int datSanId,
    String loaiThanhToan = 'deposit',
  }) async {
    dangTai = true;
    thongBaoLoi = null;
    paymentUrl = null;
    notifyListeners();

    try {
      final data = await ThanhToanApi().taoUrlVnpay(
        datSanId: datSanId,
        loaiThanhToan: loaiThanhToan,
      );

      ketQuaThanhToan = data;
      paymentUrl = (data['payment_url'] ?? '').toString();
      dangTai = false;
      notifyListeners();
      return paymentUrl ?? '';
    } catch (e) {
      thongBaoLoi = e.toString().replaceAll('Exception: ', '');
      dangTai = false;
      notifyListeners();
      return '';
    }
  }
}
