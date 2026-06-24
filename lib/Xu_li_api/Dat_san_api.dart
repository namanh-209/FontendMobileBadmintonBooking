import '../Chung/Duong_dan_api.dart';
import '../Mau_du_lieu/Dat_san.dart';
import '../Server/Goi_api.dart';

class DatSanApi {
  final GoiApi _api = GoiApi();

  List<dynamic> _layMang(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['data', 'danh_sach', 'lich_dat', 'dat_san', 'items', 'results', 'rows', 'lich_su']) {
        final value = data[key];
        if (value is List) return value;
      }
      if (data['data'] is Map) return _layMang(data['data']);
    }
    return [];
  }

  Map<String, dynamic>? _layObject(dynamic data) {
    if (data is Map && data['data'] is Map) return Map<String, dynamic>.from(data['data']);
    if (data is Map && data['dat_san'] is Map) return Map<String, dynamic>.from(data['dat_san']);
    if (data is Map && data['booking'] is Map) return Map<String, dynamic>.from(data['booking']);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  String _layNgay(List<Map<String, dynamic>> chiTiet) {
    for (final item in chiTiet) {
      final value = item['ngay'] ?? item['ngay_dat'] ?? item['date'];
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text.length >= 10 ? text.substring(0, 10) : text;
      }
    }

    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  List<Map<String, dynamic>> _laySlots(List<Map<String, dynamic>> chiTiet) {
    return chiTiet.map((item) {
      return {
        'san_id': item['san_id'] ?? item['sanId'] ?? item['id_san'],
        'khung_gio_mau_id': item['khung_gio_mau_id'] ?? item['khungGioMauId'] ?? item['khung_gio_id'],
      };
    }).where((item) {
      final sanId = int.tryParse('${item['san_id'] ?? ''}') ?? 0;
      final khungGioMauId = int.tryParse('${item['khung_gio_mau_id'] ?? ''}') ?? 0;
      return sanId > 0 && khungGioMauId > 0;
    }).toList();
  }

  Future<DatSan> taoDatSan({
    required int coSoId,
    required List<Map<String, dynamic>> chiTiet,
    String ghiChu = '',
  }) async {
    final slots = _laySlots(chiTiet);

    if (slots.isEmpty) {
      throw LoiApi('Bạn chưa chọn sân hoặc khung giờ hợp lệ');
    }

    final bodyGiuCho = {
      'co_so_id': coSoId,
      'ngay': _layNgay(chiTiet),
      'ghi_chu': ghiChu,
      'slots': slots,
    };

    final data = await _api.post(
      DuongDanApi.giuChoDatSan,
      body: bodyGiuCho,
    );

    final obj = _layObject(data);
    if (obj == null) throw LoiApi('API giữ chỗ chưa trả dữ liệu đặt sân');

    final tongTamTinh = chiTiet.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse('${item['gia'] ?? 0}') ?? 0),
    );

    return DatSan.fromJson({
      ...obj,
      if (obj['id'] == null && obj['dat_san_id'] != null) 'id': obj['dat_san_id'],
      if (obj['co_so_id'] == null) 'co_so_id': coSoId,
      if (obj['chi_tiet'] == null) 'chi_tiet': chiTiet,
      if (obj['tong_tien'] == null && obj['tongTien'] == null) 'tong_tien': tongTamTinh,
      if (obj['thanh_tien'] == null && obj['thanhTien'] == null) 'thanh_tien': tongTamTinh,
      if (obj['tien_coc'] == null && obj['tienCoc'] == null) 'tien_coc': tongTamTinh,
    });
  }

  Future<Map<String, dynamic>> giuChoTamThoi({
    required int coSoId,
    required String ngay,
    required List<Map<String, dynamic>> slots,
    String ghiChu = '',
  }) async {
    final data = await _api.post(
      DuongDanApi.giuChoDatSan,
      body: {
        'co_so_id': coSoId,
        'ngay': ngay,
        'slots': slots,
        'ghi_chu': ghiChu,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'message': 'Giữ chỗ thành công'};
  }

  Future<DatSan> giuCho({
    required int coSoId,
    required List<Map<String, dynamic>> chiTiet,
    String ghiChu = '',
  }) {
    return taoDatSan(coSoId: coSoId, chiTiet: chiTiet, ghiChu: ghiChu);
  }

  Future<List<DatSan>> layLichDatCuaToi() async {
    final endpoints = [
      DuongDanApi.lichSuDatSanCuaToi,
      '/dat-san/cua-toi',
      '/huy-dat-san/cua-toi',
      '/dat-san/lich-su',
      '/booking/my',
    ];

    Object? loiCuoi;

    for (final endpoint in endpoints) {
      try {
        final data = await _api.get(endpoint);
        return _layMang(data)
            .whereType<Map>()
            .map((item) => DatSan.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (e) {
        loiCuoi = e;
      }
    }

    if (loiCuoi is LoiApi) throw loiCuoi;
    throw LoiApi('Không lấy được lịch đặt của tôi');
  }

  Future<List<DatSan>> layLichSuDatSanCuaToi() => layLichDatCuaToi();

  Future<List<dynamic>> layLichSuCuaToi() async {
    return layLichDatCuaToi();
  }

  Future<void> huyDatSan({
    required int datSanId,
    required String lyDoHuy,
  }) async {
    await _api.patchAny(
      [
        DuongDanApi.huyGiuCho(datSanId),
        DuongDanApi.huyDatSan(datSanId),
      ],
      body: {
        'ly_do_huy': lyDoHuy,
      },
    );
  }

  Future<Map<String, dynamic>> huyGiuCho(dynamic datSanId) async {
    final data = await _api.patch(
      DuongDanApi.huyGiuCho(datSanId),
      body: {},
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'message': 'Đã hủy giữ chỗ'};
  }

  Future<Map<String, dynamic>> capNhatGhiChu({
    required int datSanId,
    required String ghiChu,
  }) async {
    final data = await _api.patch(
      DuongDanApi.capNhatGhiChuDatSan(datSanId),
      body: {
        'ghi_chu': ghiChu,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'message': 'Đã lưu ghi chú'};
  }

  Future<Map<String, dynamic>> apDungKhuyenMai({
    required int datSanId,
    String maKhuyenMai = '',
  }) async {
    final data = await _api.patch(
      DuongDanApi.apDungKhuyenMai(datSanId),
      body: {
        'ma_khuyen_mai': maKhuyenMai.trim().isEmpty ? null : maKhuyenMai.trim(),
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'message': 'Đã cập nhật khuyến mãi'};
  }

  Future<List<dynamic>> layKhuyenMaiCongKhai({
    required int coSoId,
    required double tongTien,
  }) async {
    final data = await _api.get(
      DuongDanApi.khuyenMaiCongKhai,
      query: {
        'co_so_id': coSoId,
        'tong_tien': tongTien,
      },
    );

    if (data is List) return data;
    if (data is Map) {
      final list = data['danh_sach'] ?? data['data'] ?? data['items'] ?? data['rows'];
      if (list is List) return list;
      if (data['data'] is Map) {
        final nested = data['data']['danh_sach'] ?? data['data']['items'];
        if (nested is List) return nested;
      }
    }
    return [];
  }

}
