import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/San.dart';
import '../Server/Goi_api.dart';

class SanApi {
  Future<List<San>> layDanhSachSan() async {
    final data = await GoiApi.getAny(
      [
        DuongDanApi.danhSachSan,
        '/san',
        '/admin/san',
        '/co-so/san',
      ],
    );

    return San.listFrom(data);
  }

  Future<List<San>> laySanTheoCoSo(dynamic coSoId) async {
    final data = await GoiApi.getAny(
      [
        DuongDanApi.danhSachSanTheoCoSo(coSoId),
        '/co_so/$coSoId/san',
        '/coso/$coSoId/san',
        '/san?co_so_id=$coSoId',
      ],
    );

    return San.listFrom(data);
  }

  Future<San> layChiTietSan(dynamic id) async {
    final data = await GoiApi.getAny(
      [
        DuongDanApi.chiTietSan(id),
        '/san/$id',
        '/admin/san/$id',
      ],
    );

    final map = data is Map && data['data'] is Map
        ? Map<String, dynamic>.from(data['data'])
        : Map<String, dynamic>.from(data as Map);

    return San.fromJson(map);
  }
}
