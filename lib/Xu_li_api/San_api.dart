import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/San.dart';
import '../Server/Goi_api.dart';

class SanApi {
  final GoiApi _api = GoiApi();

  List<dynamic> _layMang(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['data', 'san', 'dsSan', 'danh_sach', 'danhSach', 'items', 'results', 'rows']) {
        final value = data[key];
        if (value is List) return value;
      }
      if (data['data'] is Map) return _layMang(data['data']);
    }
    return [];
  }

  Future<List<San>> layDanhSachSan({dynamic coSoId}) async {
    final data = await _api.get(
      DuongDanApi.danhSachSan,
      query: {
        if (coSoId != null && '$coSoId'.trim().isNotEmpty) 'co_so_id': coSoId,
      },
    );

    return _layMang(data)
        .whereType<Map>()
        .map((item) => San.fromJson(Map<String, dynamic>.from(item)))
        .where((san) => san.trangThai != 2)
        .toList();
  }

  Future<List<San>> laySanTheoCoSo(dynamic coSoId) {
    return layDanhSachSan(coSoId: coSoId);
  }

  Future<San> layChiTietSan(dynamic id) async {
    final data = await _api.get(DuongDanApi.chiTietSan(id));

    if (data is Map && data['data'] is Map) {
      return San.fromJson(Map<String, dynamic>.from(data['data']));
    }

    if (data is Map && data['san'] is Map) {
      return San.fromJson(Map<String, dynamic>.from(data['san']));
    }

    if (data is Map) {
      return San.fromJson(Map<String, dynamic>.from(data));
    }

    throw LoiApi('Không đọc được chi tiết sân');
  }
}
