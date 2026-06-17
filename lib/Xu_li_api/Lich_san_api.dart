import '../Chung/Duong_dan_api.dart';
import '../Server/Goi_api.dart';

class LichSanApi {
  static Future<List<dynamic>> layLichSan(
    dynamic sanId, {
    String? ngay,
  }) async {
    final data = await GoiApi.getAny(
      [
        DuongDanApi.lichSan(sanId, ngay: ngay),
        ngay == null
            ? '/lich-san/$sanId'
            : '/lich-san/$sanId?ngay=$ngay',
        ngay == null
            ? '/san/$sanId/lich'
            : '/san/$sanId/lich?ngay=$ngay',
      ],
    );

    if (data is List) return data;

    if (data is Map) {
      final list = data['slots'] ?? data['data'] ?? data['lich'] ?? data['lich_san'] ?? data['items'];

      if (list is List) return list;
    }

    return [];
  }

  static Future<List<dynamic>> layLichCoSo(
    dynamic coSoId, {
    String? ngay,
  }) async {
    final data = await GoiApi.getAny(
      [
        DuongDanApi.lichTheoCoSo(coSoId, ngay: ngay),
        ngay == null
            ? '/dat-san/lich?co_so_id=$coSoId'
            : '/dat-san/lich?co_so_id=$coSoId&ngay=$ngay',
        ngay == null
            ? '/co_so/$coSoId/lich'
            : '/co_so/$coSoId/lich?ngay=$ngay',
        ngay == null
            ? '/coso/$coSoId/lich'
            : '/coso/$coSoId/lich?ngay=$ngay',
      ],
    );

    if (data is List) return data;

    if (data is Map) {
      final list = data['san'] ?? data['data'] ?? data['lich'] ?? data['items'];

      if (list is List) return list;
    }

    return [];
  }
}
