import '../Chung/Duong_dan_api.dart';
import 'San.dart';

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

class CoSo {
  final int id;
  final int chuSoId;
  final String ten;
  final String diaChi;
  final String phuongXa;
  final String tinhThanh;
  final String moTa;
  final String hinhAnh;
  final double danhGia;
  final double giaThapNhat;
  final double viDo;
  final double kinhDo;
  final int trangThai;
  final int trangThaiDuyet;
  final double phanTramCoc;
  final int soLuongSan;
  final List<San> danhSachSan;

  CoSo({
    required this.id,
    this.chuSoId = 0,
    String? ten,
    String? tenCoSo,
    this.diaChi = '',
    this.phuongXa = '',
    this.tinhThanh = '',
    this.moTa = '',
    this.hinhAnh = '',
    this.danhGia = 0,
    this.giaThapNhat = 0,
    this.viDo = 0,
    this.kinhDo = 0,
    this.trangThai = 1,
    this.trangThaiDuyet = 1,
    this.phanTramCoc = 30,
    this.soLuongSan = 0,
    this.danhSachSan = const [],
  }) : ten = ten ?? tenCoSo ?? '';

  String get tenCoSo => ten;
  String get anhChinh => hinhAnh;
  bool get dangHoatDong => trangThai == 1 && trangThaiDuyet == 1;

  factory CoSo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;

    final rawAnh = data['hinh_anh'] ??
        data['hinhAnh'] ??
        data['anh_chinh'] ??
        data['url_anh'] ??
        data['avatar'] ??
        data['url'] ??
        data['image'] ??
        '';

    final rawSan = data['danh_sach_san'] ?? data['san'] ?? data['ds_san'] ?? data['danhSachSan'];
    final dsSan = <San>[];

    if (rawSan is List) {
      for (final item in rawSan) {
        if (item is Map) {
          dsSan.add(San.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return CoSo(
      id: _intTuJson(data['id'] ?? data['co_so_id'] ?? data['coSoId']),
      chuSoId: _intTuJson(data['chu_so_id'] ?? data['chuSoId']),
      ten: '${data['ten'] ?? data['ten_co_so'] ?? data['tenCoSo'] ?? data['name'] ?? 'Sân cầu lông'}',
      diaChi: '${data['dia_chi'] ?? data['diaChi'] ?? data['address'] ?? ''}',
      phuongXa: '${data['phuong_xa'] ?? data['phuongXa'] ?? data['ward'] ?? ''}',
      tinhThanh: '${data['tinh_thanh'] ?? data['tinhThanh'] ?? data['city'] ?? data['province'] ?? 'TP.HCM'}',
      moTa: '${data['mo_ta'] ?? data['moTa'] ?? data['description'] ?? ''}',
      hinhAnh: DuongDanApi.anh('$rawAnh'),
      danhGia: _doubleTuJson(data['danh_gia'] ?? data['danhGia'] ?? data['diem_danh_gia'] ?? data['rating']),
      giaThapNhat: _doubleTuJson(data['gia_thap_nhat'] ?? data['giaThapNhat'] ?? data['gia'] ?? data['price']),
      viDo: _doubleTuJson(data['vi_do'] ?? data['viDo'] ?? data['lat'] ?? data['latitude']),
      kinhDo: _doubleTuJson(data['kinh_do'] ?? data['kinhDo'] ?? data['lng'] ?? data['longitude']),
      trangThai: _intTuJson(data['trang_thai'] ?? data['trangThai'] ?? 1),
      trangThaiDuyet: _intTuJson(data['trang_thai_duyet'] ?? data['trangThaiDuyet'] ?? 1),
      phanTramCoc: _doubleTuJson(data['phan_tram_coc'] ?? data['phanTramCoc'] ?? 30),
      soLuongSan: _intTuJson(data['so_luong_san'] ?? data['soLuongSan'] ?? data['tong_san'] ?? dsSan.length),
      danhSachSan: dsSan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chu_so_id': chuSoId,
      'ten': ten,
      'ten_co_so': tenCoSo,
      'dia_chi': diaChi,
      'phuong_xa': phuongXa,
      'tinh_thanh': tinhThanh,
      'mo_ta': moTa,
      'hinh_anh': hinhAnh,
      'danh_gia': danhGia,
      'gia_thap_nhat': giaThapNhat,
      'vi_do': viDo,
      'kinh_do': kinhDo,
      'trang_thai': trangThai,
      'trang_thai_duyet': trangThaiDuyet,
      'phan_tram_coc': phanTramCoc,
      'so_luong_san': soLuongSan,
      'danh_sach_san': danhSachSan.map((e) => e.toJson()).toList(),
    };
  }

  CoSo copyWith({
    int? id,
    int? chuSoId,
    String? ten,
    String? diaChi,
    String? phuongXa,
    String? tinhThanh,
    String? moTa,
    String? hinhAnh,
    double? danhGia,
    double? giaThapNhat,
    double? viDo,
    double? kinhDo,
    int? trangThai,
    int? trangThaiDuyet,
    double? phanTramCoc,
    int? soLuongSan,
    List<San>? danhSachSan,
  }) {
    return CoSo(
      id: id ?? this.id,
      chuSoId: chuSoId ?? this.chuSoId,
      ten: ten ?? this.ten,
      diaChi: diaChi ?? this.diaChi,
      phuongXa: phuongXa ?? this.phuongXa,
      tinhThanh: tinhThanh ?? this.tinhThanh,
      moTa: moTa ?? this.moTa,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      danhGia: danhGia ?? this.danhGia,
      giaThapNhat: giaThapNhat ?? this.giaThapNhat,
      viDo: viDo ?? this.viDo,
      kinhDo: kinhDo ?? this.kinhDo,
      trangThai: trangThai ?? this.trangThai,
      trangThaiDuyet: trangThaiDuyet ?? this.trangThaiDuyet,
      phanTramCoc: phanTramCoc ?? this.phanTramCoc,
      soLuongSan: soLuongSan ?? this.soLuongSan,
      danhSachSan: danhSachSan ?? this.danhSachSan,
    );
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
}
