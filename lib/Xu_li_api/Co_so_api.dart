import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Mau_du_lieu/Lich_co_so.dart';
import '../Server/Goi_api.dart';

class CoSoApi {
  Future<List<CoSo>> layDanhSachCoSo({
    String? tuKhoa,
    String? tinhThanh,
    String? phuongXa,
    String? loaiSan,
    num? giaTu,
    num? giaDen,
    String? ngay,
    String? gio,
    String? sapXep,
  }) async {
    final data = await GoiApi.get(
      DuongDanApi.danhSachCoSoLoc(
        tuKhoa: tuKhoa,
        tinhThanh: tinhThanh,
        phuongXa: phuongXa,
        loaiSan: loaiSan,
        giaTu: giaTu,
        giaDen: giaDen,
        ngay: ngay,
        gio: gio,
        sapXep: sapXep,
      ),
    );

    return CoSo.listFrom(data);
  }

  Future<CoSo> layChiTietCoSo(dynamic id) async {
    final data = await GoiApi.get(DuongDanApi.chiTietCoSo(id));

    final map = data is Map && data['data'] is Map
        ? Map<String, dynamic>.from(data['data'])
        : Map<String, dynamic>.from(data as Map);

    return CoSo.fromJson(map);
  }

  Future<List<LichSanCon>> layLichCoSo({
    required dynamic coSoId,
    required String ngay,
  }) async {
    final data = await GoiApi.get(DuongDanApi.lichTheoCoSo(coSoId, ngay: ngay));

    final list = data is Map
        ? (data['san'] ?? data['data'] ?? data['lich'] ?? data['lich_san'] ?? data['items'] ?? [])
        : data;

    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => LichSanCon.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
