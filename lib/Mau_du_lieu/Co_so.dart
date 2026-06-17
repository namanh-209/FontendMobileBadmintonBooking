import '../Chung/Duong_dan_api.dart';

class CoSo {
  final int id;
  final String ten;
  final String tenCoSo;
  final String diaChi;
  final String phuongXa;
  final String tinhThanh;
  final String moTa;
  final String hinhAnh;
  final double danhGia;
  final double giaThapNhat;
  final int soLuongSan;
  final double viDo;
  final double kinhDo;

  CoSo({
    required this.id,
    String? ten,
    String? tenCoSo,
    this.diaChi = '',
    this.phuongXa = '',
    this.tinhThanh = '',
    this.moTa = '',
    this.hinhAnh = '',
    this.danhGia = 0,
    this.giaThapNhat = 0,
    this.soLuongSan = 0,
    this.viDo = 0,
    this.kinhDo = 0,
  })  : ten = ten ?? tenCoSo ?? 'Cơ sở cầu lông',
        tenCoSo = tenCoSo ?? ten ?? 'Cơ sở cầu lông';

  factory CoSo.fromJson(Map<String, dynamic> json) {
    final map = _unwrap(json);

    final tenLayDuoc = (map['ten_co_so'] ??
            map['tenCoSo'] ??
            map['ten'] ??
            map['name'] ??
            map['title'] ??
            'Cơ sở cầu lông')
        .toString();

    return CoSo(
      id: _toInt(map['id'] ?? map['co_so_id'] ?? map['coSoId']) ?? 0,
      ten: tenLayDuoc,
      tenCoSo: tenLayDuoc,
      diaChi: (map['dia_chi'] ?? map['diaChi'] ?? map['address'] ?? '').toString(),
      phuongXa: (map['phuong_xa'] ?? map['phuongXa'] ?? map['ward'] ?? '').toString(),
      tinhThanh: (map['tinh_thanh'] ?? map['tinhThanh'] ?? map['city'] ?? map['province'] ?? '').toString(),
      moTa: (map['mo_ta'] ?? map['moTa'] ?? map['description'] ?? '').toString(),
      hinhAnh: _chuanHoaAnh(
        map['anh_chinh'] ??
            map['hinh_anh'] ??
            map['hinhAnh'] ??
            map['url'] ??
            map['image'] ??
            '',
      ),
      danhGia: _toDouble(map['danh_gia'] ?? map['danhGia'] ?? map['rating']) ?? 0,
      giaThapNhat: _toDouble(map['gia_thap_nhat'] ?? map['giaThapNhat'] ?? map['gia'] ?? map['price']) ?? 0,
      soLuongSan: _toInt(
            map['so_luong_san'] ??
                map['soLuongSan'] ??
                map['so_san'] ??
                map['tong_san'] ??
                map['total_courts'],
          ) ??
          0,
      viDo: _toDouble(map['vi_do'] ?? map['viDo'] ?? map['latitude'] ?? map['lat']) ?? 0,
      kinhDo: _toDouble(map['kinh_do'] ?? map['kinhDo'] ?? map['longitude'] ?? map['lng']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ten': ten,
      'ten_co_so': tenCoSo,
      'dia_chi': diaChi,
      'phuong_xa': phuongXa,
      'tinh_thanh': tinhThanh,
      'mo_ta': moTa,
      'hinh_anh': hinhAnh,
      'danh_gia': danhGia,
      'gia_thap_nhat': giaThapNhat,
      'so_luong_san': soLuongSan,
      'vi_do': viDo,
      'kinh_do': kinhDo,
    };
  }

  static List<CoSo> listFrom(dynamic data) {
    final list = data is Map
        ? (data['data'] ?? data['co_so'] ?? data['coSo'] ?? data['items'] ?? data['rows'] ?? [])
        : data;

    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => CoSo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    if (json['data'] is Map) return Map<String, dynamic>.from(json['data']);
    if (json['co_so'] is Map) return Map<String, dynamic>.from(json['co_so']);
    if (json['coSo'] is Map) return Map<String, dynamic>.from(json['coSo']);
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
