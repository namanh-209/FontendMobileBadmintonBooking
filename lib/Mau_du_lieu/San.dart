import '../Chung/Duong_dan_api.dart';

double _doubleTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

int _intTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

class San {
  final int id;
  final int sanId;
  final int coSoId;
  final String ten;
  final int danhMucSanId;
  final String tenDanhMuc;
  final String tenCoSo;
  final String diaChi;
  final String danhMuc;
  final String hinhAnh;
  final int trangThai;
  final double gia;
  final double giaThapNhat;
  final double viDo;
  final double kinhDo;

  San({
    int? id,
    int? sanId,
    this.coSoId = 0,
    String? ten,
    String? tenSan,
    this.danhMucSanId = 0,
    this.tenDanhMuc = '',
    this.tenCoSo = '',
    this.diaChi = '',
    this.danhMuc = '',
    this.hinhAnh = '',
    this.trangThai = 1,
    this.gia = 0,
    this.giaThapNhat = 0,
    this.viDo = 0,
    this.kinhDo = 0,
  })  : id = id ?? sanId ?? 0,
        sanId = sanId ?? id ?? 0,
        ten = ten ?? tenSan ?? '';

  String get tenSan => ten;
  String get anhChinh => hinhAnh;
  bool get dangHoatDong => trangThai == 1;

  factory San.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;

    final rawAnh = data['hinh_anh'] ??
        data['url_anh'] ??
        data['anh_chinh'] ??
        data['hinhAnh'] ??
        data['avatar'] ??
        data['url'] ??
        data['image'] ??
        '';

    final idLayDuoc = _intTuJson(data['id'] ?? data['san_id'] ?? data['sanId']);

    return San(
      id: idLayDuoc,
      sanId: idLayDuoc,
      coSoId: _intTuJson(data['co_so_id'] ?? data['coSoId']),
      ten: '${data['ten'] ?? data['ten_san'] ?? data['tenSan'] ?? data['name'] ?? 'Sân cầu lông'}',
      danhMucSanId: _intTuJson(data['danh_muc_san_id'] ?? data['danhMucSanId']),
      tenDanhMuc: '${data['ten_danh_muc'] ?? data['tenDanhMuc'] ?? ''}',
      tenCoSo: '${data['ten_co_so'] ?? data['tenCoSo'] ?? ''}',
      diaChi: '${data['dia_chi'] ?? data['diaChi'] ?? data['address'] ?? ''}',
      danhMuc: '${data['danh_muc'] ?? data['ten_danh_muc'] ?? data['category'] ?? ''}',
      hinhAnh: DuongDanApi.anh('$rawAnh'),
      trangThai: _intTuJson(data['trang_thai'] ?? data['trangThai'] ?? 1),
      gia: _doubleTuJson(data['gia'] ?? data['gia_hien_tai'] ?? data['price']),
      giaThapNhat: _doubleTuJson(data['gia_thap_nhat'] ?? data['giaThapNhat'] ?? data['gia'] ?? data['price']),
      viDo: _doubleTuJson(data['vi_do'] ?? data['viDo'] ?? data['lat'] ?? data['latitude']),
      kinhDo: _doubleTuJson(data['kinh_do'] ?? data['kinhDo'] ?? data['lng'] ?? data['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'san_id': sanId,
      'co_so_id': coSoId,
      'ten': ten,
      'ten_san': tenSan,
      'danh_muc_san_id': danhMucSanId,
      'ten_danh_muc': tenDanhMuc,
      'ten_co_so': tenCoSo,
      'dia_chi': diaChi,
      'danh_muc': danhMuc,
      'hinh_anh': hinhAnh,
      'trang_thai': trangThai,
      'gia': gia,
      'gia_thap_nhat': giaThapNhat,
      'vi_do': viDo,
      'kinh_do': kinhDo,
    };
  }

  static List<San> listFrom(dynamic data) {
    final list = data is Map
        ? (data['data'] ?? data['san'] ?? data['sans'] ?? data['items'] ?? data['rows'] ?? [])
        : data;

    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => San.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
