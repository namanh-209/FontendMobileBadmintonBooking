import '../Chung/Duong_dan_api.dart';

class San {
  final int id;
  final int sanId;
  final int coSoId;
  final String ten;
  final String tenSan;
  final String tenCoSo;
  final String diaChi;
  final String danhMuc;
  final String trangThai;
  final String hinhAnh;
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
    this.tenCoSo = '',
    this.diaChi = '',
    this.danhMuc = '',
    this.trangThai = '',
    this.hinhAnh = '',
    this.gia = 0,
    double? giaThapNhat,
    this.viDo = 0,
    this.kinhDo = 0,
  })  : id = id ?? sanId ?? 0,
        sanId = sanId ?? id ?? 0,
        ten = ten ?? tenSan ?? 'Sân cầu lông',
        tenSan = tenSan ?? ten ?? 'Sân cầu lông',
        giaThapNhat = giaThapNhat ?? gia;

  factory San.fromJson(Map<String, dynamic> json) {
    final map = _unwrap(json);
    final idLayDuoc = _toInt(map['id'] ?? map['san_id'] ?? map['sanId']) ?? 0;
    final tenLayDuoc = (map['ten_san'] ?? map['tenSan'] ?? map['ten'] ?? map['name'] ?? 'Sân cầu lông').toString();
    final giaLayDuoc = _toDouble(map['gia_thap_nhat'] ?? map['giaThapNhat'] ?? map['gia'] ?? map['price']) ?? 0;

    return San(
      id: idLayDuoc,
      sanId: idLayDuoc,
      coSoId: _toInt(map['co_so_id'] ?? map['coSoId']) ?? 0,
      ten: tenLayDuoc,
      tenSan: tenLayDuoc,
      tenCoSo: (map['ten_co_so'] ?? map['tenCoSo'] ?? '').toString(),
      diaChi: (map['dia_chi'] ?? map['diaChi'] ?? map['address'] ?? '').toString(),
      danhMuc: (map['danh_muc'] ?? map['ten_danh_muc'] ?? map['category'] ?? '').toString(),
      trangThai: (map['trang_thai'] ?? map['status'] ?? '').toString(),
      hinhAnh: _chuanHoaAnh(map['anh_chinh'] ?? map['hinh_anh'] ?? map['hinhAnh'] ?? map['url'] ?? map['image'] ?? ''),
      gia: giaLayDuoc,
      giaThapNhat: giaLayDuoc,
      viDo: _toDouble(map['vi_do'] ?? map['viDo'] ?? map['latitude'] ?? map['lat']) ?? 0,
      kinhDo: _toDouble(map['kinh_do'] ?? map['kinhDo'] ?? map['longitude'] ?? map['lng']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'san_id': sanId,
      'co_so_id': coSoId,
      'ten': ten,
      'ten_san': tenSan,
      'ten_co_so': tenCoSo,
      'dia_chi': diaChi,
      'danh_muc': danhMuc,
      'trang_thai': trangThai,
      'hinh_anh': hinhAnh,
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

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    if (json['data'] is Map) return Map<String, dynamic>.from(json['data']);
    if (json['san'] is Map) return Map<String, dynamic>.from(json['san']);
    return json;
  }

  static String _chuanHoaAnh(dynamic value) {
    dynamic anh = value;

    if (anh is List && anh.isNotEmpty) {
      final dauTien = anh.first;
      if (dauTien is Map) {
        anh = dauTien['url'] ?? dauTien['duong_dan'] ?? dauTien['image'] ?? '';
      } else {
        anh = dauTien;
      }
    }

    final url = anh?.toString() ?? '';
    return DuongDanApi.linkAnh(url);
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
