import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';

class DatSanApi {
  Future<Map<String, dynamic>> giuChoTamThoi({
    required int coSoId,
    required String ngay,
    required List<Map<String, dynamic>> slots,
    String ghiChu = '',
  }) async {
    final data = await GoiApi.post(
      DuongDanApi.giuChoDatSan,
      {
        'co_so_id': coSoId,
        'ngay': ngay,
        'slots': slots,
        'ghi_chu': ghiChu,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    return {
      'message': 'Giữ chỗ thành công',
    };
  }

  Future<List<dynamic>> layLichSuCuaToi() async {
    final data = await GoiApi.get(DuongDanApi.lichSuDatSanCuaToi);

    if (data is List) return data;

    if (data is Map) {
      final list = data['data'] ?? data['items'] ?? data['lich_su'];
      if (list is List) return list;
    }

    return [];
  }

  Future<List<DatSan>> layLichSuDatSanCuaToi() async {
    final data = await GoiApi.get(DuongDanApi.lichSuDatSanCuaToi);
    return DatSan.listFrom(data);
  }

  Future<Map<String, dynamic>> huyGiuCho(dynamic datSanId) async {
    final data = await GoiApi.patch(
      DuongDanApi.huyGiuCho(datSanId),
      {},
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    return {
      'message': 'Đã hủy giữ chỗ',
    };
  }
}
