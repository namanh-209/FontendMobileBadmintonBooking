import '../Chung/Duong_dan_api.dart';
import '../Server/Goi_api.dart';

class YeuThichApi {
  final GoiApi _api = GoiApi();

  Future<List<int>> layDanhSachYeuThich() async {
    final data = await _api.get(DuongDanApi.danhSachYeuThich);

    final list = data is Map ? (data['data'] ?? data['items'] ?? []) : data;

    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => int.tryParse((e['co_so_id'] ?? e['id'] ?? '').toString()))
        .whereType<int>()
        .toList();
  }

  Future<void> themYeuThich(int coSoId) async {
    await _api.post(
      DuongDanApi.themYeuThich(coSoId),
      body: {},
    );
  }

  Future<void> xoaYeuThich(int coSoId) async {
    await _api.delete(DuongDanApi.xoaYeuThich(coSoId));
  }

  Future<bool> kiemTraYeuThich(int coSoId) async {
    try {
      final data = await _api.get(DuongDanApi.kiemTraYeuThich(coSoId));

      if (data is Map) {
        return data['isFavorite'] == true ||
            data['is_favorite'] == true ||
            data['da_yeu_thich'] == true ||
            data['isFavorite'].toString() == '1' ||
            data['is_favorite'].toString() == '1';
      }
    } catch (_) {}

    final list = await layDanhSachYeuThich();
    return list.contains(coSoId);
  }
}
