import '../Chung/Duong_dan_api.dart';
import '../Server/Goi_api.dart';

class ThanhToanApi {
  Future<Map<String, dynamic>> taoUrlVnpay({
    required int datSanId,
    String loaiThanhToan = 'deposit',
  }) async {
    final data = await GoiApi.post(
      DuongDanApi.taoUrlThanhToanVnpay,
      {
        'dat_san_id': datSanId,
        'loai_thanh_toan': loaiThanhToan,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    return {};
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
}
