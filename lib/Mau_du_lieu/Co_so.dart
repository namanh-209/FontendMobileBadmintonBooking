import '../Chung/Duong_dan_api.dart';
import 'San.dart';

double _doubleTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();

  var text = '$value'
      .replaceAll('đ', '')
      .replaceAll(' ', '')
      .trim();

  if (text.contains('.') && text.contains(',')) {
    text = text.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
    text = text.replaceAll('.', '');
  } else {
    text = text.replaceAll(',', '.');
  }

  return double.tryParse(text) ?? 0;
}

int _intTuJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();

  final text = '$value'.trim();
  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
}

Map<String, dynamic> _layMapDuLieu(Map<String, dynamic> json) {
  final data = json['data'];

  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }

  return json;
}

List<San> _layDanhSachSan(Map<String, dynamic> data) {
  final rawSan = data['danh_sach_san'] ??
      data['danhSachSan'] ??
      data['ds_san'] ??
      data['dsSan'] ??
      data['san'] ??
      data['sans'] ??
      data['san_con'] ??
      data['sanCon'] ??
      data['san_bai'] ??
      data['sanBai'] ??
      data['courts'] ??
      data['court'] ??
      data['fields'];

  final dsSan = <San>[];

  if (rawSan is List) {
    for (final item in rawSan) {
      if (item is Map) {
        dsSan.add(
          San.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }
  }

  return dsSan;
}


String _layTextAnh(dynamic value) {
  if (value == null) return '';

  if (value is String) {
    final text = value.trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  if (value is List) {
    for (final item in value) {
      final text = _layTextAnh(item);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  if (value is Map) {
    final map = Map<String, dynamic>.from(value);

    final keys = [
      'url',
      'secure_url',
      'src',
      'path',
      'duong_dan',
      'duongDan',
      'link',
      'image',
      'image_url',
      'imageUrl',
      'hinh_anh',
      'hinhAnh',
      'anh_chinh',
      'anhChinh',
      'url_anh',
      'urlAnh',
      'thumbnail',
      'avatar',
      'file',
      'filename',
      'ten_file',
      'tenFile',
      'public_url',
      'publicUrl',
      'location',
    ];

    for (final key in keys) {
      final text = _layTextAnh(map[key]);
      if (text.isNotEmpty) return text;
    }

    final data = map['data'];
    final textData = _layTextAnh(data);
    if (textData.isNotEmpty) return textData;
  }

  return '';
}

String _layAnhCoSo(Map<String, dynamic> data) {
  final keys = [
    'hinh_anh',
    'hinhAnh',
    'anh_chinh',
    'anhChinh',
    'url_anh',
    'urlAnh',
    'anh',
    'image',
    'image_url',
    'imageUrl',
    'thumbnail',
    'thumbnail_url',
    'thumbnailUrl',
    'avatar',
    'url',
    'cover',
    'cover_image',
    'coverImage',
    'banner',
    'photo',
    'photos',
    'images',
    'hinh_anhs',
    'hinhAnhs',
    'danh_sach_anh',
    'danhSachAnh',
    'album',
    'media',
  ];

  for (final key in keys) {
    final text = _layTextAnh(data[key]);
    if (text.isNotEmpty) return text;
  }

  return '';
}

int _laySoLuongSan(Map<String, dynamic> data, List<San> dsSan) {
  final cacKeySoLuong = [
    'so_luong_san',
    'soLuongSan',
    'so_san',
    'soSan',
    'tong_san',
    'tongSan',
    'tong_so_san',
    'tongSoSan',
    'sl_san',
    'slSan',
    'soluong_san',
    'soluongSan',
    'san_count',
    'sanCount',
    'count_san',
    'countSan',
    'so_luong_san_con',
    'soLuongSanCon',
    'tong_san_con',
    'tongSanCon',
    'court_count',
    'courtCount',
    'courts_count',
    'courtsCount',
    'total_courts',
    'totalCourts',
    'number_of_courts',
    'numberOfCourts',
  ];

  for (final key in cacKeySoLuong) {
    final value = data[key];

    if (value is List) {
      if (value.isNotEmpty) return value.length;
      continue;
    }

    final soLuong = _intTuJson(value);
    if (soLuong > 0) return soLuong;
  }

  final cacKeyDanhSachSan = [
    'danh_sach_san',
    'danhSachSan',
    'ds_san',
    'dsSan',
    'san',
    'sans',
    'san_con',
    'sanCon',
    'san_bai',
    'sanBai',
    'courts',
    'court',
    'fields',
  ];

  for (final key in cacKeyDanhSachSan) {
    final value = data[key];

    if (value is List && value.isNotEmpty) {
      return value.length;
    }
  }

  if (dsSan.isNotEmpty) {
    return dsSan.length;
  }

  return 0;
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
    final data = _layMapDuLieu(json);

    final rawAnh = _layAnhCoSo(data);

    final dsSan = _layDanhSachSan(data);
    final soLuongSanDocDuoc = _laySoLuongSan(data, dsSan);

    return CoSo(
      id: _intTuJson(
        data['id'] ??
            data['co_so_id'] ??
            data['coSoId'] ??
            data['coso_id'] ??
            data['cosoId'],
      ),
      chuSoId: _intTuJson(
        data['chu_so_id'] ??
            data['chuSoId'] ??
            data['user_id'] ??
            data['userId'] ??
            data['owner_id'] ??
            data['ownerId'],
      ),
      ten:
          '${data['ten'] ?? data['ten_co_so'] ?? data['tenCoSo'] ?? data['name'] ?? data['title'] ?? 'Sân cầu lông'}',
      diaChi:
          '${data['dia_chi'] ?? data['diaChi'] ?? data['address'] ?? data['location'] ?? ''}',
      phuongXa:
          '${data['phuong_xa'] ?? data['phuongXa'] ?? data['ward'] ?? ''}',
      tinhThanh:
          '${data['tinh_thanh'] ?? data['tinhThanh'] ?? data['city'] ?? data['province'] ?? 'TP.HCM'}',
      moTa:
          '${data['mo_ta'] ?? data['moTa'] ?? data['description'] ?? data['ghi_chu'] ?? ''}',
      hinhAnh: DuongDanApi.anh(rawAnh),
      danhGia: _doubleTuJson(
        data['danh_gia'] ??
            data['danhGia'] ??
            data['diem_danh_gia'] ??
            data['diemDanhGia'] ??
            data['rating'] ??
            data['rate'],
      ),
      giaThapNhat: _doubleTuJson(
        data['gia_thap_nhat'] ??
            data['giaThapNhat'] ??
            data['gia'] ??
            data['price'] ??
            data['min_price'] ??
            data['minPrice'] ??
            data['gia_san'] ??
            data['giaSan'],
      ),
      viDo: _doubleTuJson(
        data['vi_do'] ??
            data['viDo'] ??
            data['lat'] ??
            data['latitude'],
      ),
      kinhDo: _doubleTuJson(
        data['kinh_do'] ??
            data['kinhDo'] ??
            data['lng'] ??
            data['longitude'],
      ),
      trangThai: _intTuJson(
        data['trang_thai'] ??
            data['trangThai'] ??
            data['status'] ??
            1,
      ),
      trangThaiDuyet: _intTuJson(
        data['trang_thai_duyet'] ??
            data['trangThaiDuyet'] ??
            data['duyet'] ??
            data['approved'] ??
            1,
      ),
      phanTramCoc: _doubleTuJson(
        data['phan_tram_coc'] ??
            data['phanTramCoc'] ??
            data['deposit_percent'] ??
            data['depositPercent'] ??
            30,
      ),
      soLuongSan: soLuongSanDocDuoc,
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
        ? (data['data'] ??
            data['co_so'] ??
            data['coSo'] ??
            data['coso'] ??
            data['items'] ??
            data['rows'] ??
            data['results'] ??
            data['facilities'] ??
            data['san'] ??
            [])
        : data;

    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map(
          (e) => CoSo.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }
}