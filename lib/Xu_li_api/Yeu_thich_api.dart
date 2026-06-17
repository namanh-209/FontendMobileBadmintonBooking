import '../Chung/Duong_dan_api.dart';
import '../Server/Goi_api.dart';

class YeuThichApi {
  Future<List<int>> layDanhSachYeuThich() async {
    final data = await GoiApi.get(DuongDanApi.danhSachYeuThich);

    final list = data is Map ? (data['data'] ?? data['items'] ?? []) : data;

    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => int.tryParse((e['co_so_id'] ?? e['id'] ?? '').toString()))
        .whereType<int>()
        .toList();
  }

  Future<void> themYeuThich(int coSoId) async {
    await GoiApi.post(
      DuongDanApi.themYeuThich(coSoId),
      {},
    );
  }

  Future<void> xoaYeuThich(int coSoId) async {
    await GoiApi.delete(DuongDanApi.xoaYeuThich(coSoId));
  }

  Future<bool> kiemTraYeuThich(int coSoId) async {
    final data = await GoiApi.get(DuongDanApi.kiemTraYeuThich(coSoId));

    if (data is Map) {
      return data['isFavorite'] == true || data['isFavorite'].toString() == '1';
    }

    return false;
  }
}
