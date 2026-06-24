import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Co_so.dart';
import '../Server/Goi_api.dart';

class CoSoApi {
  final GoiApi _api = GoiApi();

  List<dynamic> _layMang(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['data', 'co_so', 'dsCoSo', 'danh_sach', 'danhSach', 'items', 'results', 'rows']) {
        final value = data[key];
        if (value is List) return value;
      }
      if (data['data'] is Map) return _layMang(data['data']);
    }
    return [];
  }

  Map<String, dynamic>? _layObject(dynamic data) {
    if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data']);
    if (data is Map && data['co_so'] is Map) return Map<String, dynamic>.from(data['co_so']);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

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
    try {
      final data = await _api.get(
        DuongDanApi.danhSachCoSo,
        query: {
          'tu_khoa': tuKhoa,
          'tinh_thanh': tinhThanh,
          'phuong_xa': phuongXa,
          'loai_san': loaiSan,
          'gia_tu': giaTu,
          'gia_den': giaDen,
          'ngay': ngay,
          'gio': gio,
          'sap_xep': sapXep,
        },
      );

      final list = _layMang(data)
          .whereType<Map>()
          .map((item) => CoSo.fromJson(Map<String, dynamic>.from(item)))
          .where((coSo) => coSo.trangThai != 2)
          .toList();

      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback bên dưới nếu route /co-so chưa trả dữ liệu.
    }

    final dataSan = await _api.get(DuongDanApi.danhSachSan);
    final mapCoSo = <int, CoSo>{};

    for (final item in _layMang(dataSan)) {
      if (item is! Map) continue;
      final json = Map<String, dynamic>.from(item);
      final coSoId = int.tryParse('${json['co_so_id'] ?? json['coSoId'] ?? 0}') ?? 0;
      if (coSoId <= 0) continue;

      mapCoSo.putIfAbsent(
        coSoId,
        () => CoSo.fromJson({
          'id': coSoId,
          'ten': json['ten_co_so'] ?? json['tenCoSo'] ?? 'Cơ sở $coSoId',
          'dia_chi': json['dia_chi'] ?? json['diaChi'] ?? '',
          'phuong_xa': json['phuong_xa'] ?? '',
          'tinh_thanh': json['tinh_thanh'] ?? 'TP.HCM',
          'hinh_anh': json['anh_chinh'] ?? json['hinh_anh'] ?? json['url_anh'] ?? '',
          'gia_thap_nhat': json['gia_thap_nhat'] ?? json['gia'] ?? 0,
          'trang_thai': 1,
          'trang_thai_duyet': 1,
        }),
      );
    }

    return mapCoSo.values.toList();
  }

  Future<CoSo> layChiTietCoSo(dynamic id) async {
    final endpoints = [
      DuongDanApi.chiTietCoSo(id),
      '/xem-co-so/$id',
      '/co-so/chi-tiet/$id',
    ];

    Object? loiCuoi;

    for (final endpoint in endpoints) {
      try {
        final data = await _api.get(endpoint);
        final obj = _layObject(data);
        if (obj != null) return CoSo.fromJson(obj);
      } catch (e) {
        loiCuoi = e;
      }
    }

    try {
      final danhSach = await layDanhSachCoSo();
      return danhSach.firstWhere(
        (coSo) => coSo.id.toString() == id.toString(),
        orElse: () => CoSo(id: int.tryParse('$id') ?? 0, ten: 'Cơ sở $id'),
      );
    } catch (_) {
      if (loiCuoi is LoiApi) throw loiCuoi;
      throw LoiApi('Không lấy được chi tiết cơ sở');
    }
  }

  Future<List<dynamic>> layLichCoSo(dynamic coSoId, {String? ngay}) async {
    final data = await _api.get(
      DuongDanApi.lichDatSanCongKhai,
      query: {
        'co_so_id': coSoId,
        'ngay': ngay,
      },
    );

    if (data is Map) {
      final list = data['san'] ?? data['data'] ?? data['lich'] ?? data['items'];
      if (list is List) return list;
    }
    if (data is List) return data;
    return [];
  }
}
