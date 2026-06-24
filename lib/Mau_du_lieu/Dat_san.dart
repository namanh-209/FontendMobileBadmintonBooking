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

DateTime? _dateTuJson(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  if (text.isEmpty || text == 'null') return null;
  return DateTime.tryParse(text);
}

String _catNgay(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}

String _catGio(dynamic value) {
  final text = value?.toString() ?? '';
  if (text.length >= 5) return text.substring(0, 5);
  return text;
}

class ChiTietDatSan {
  final int id;
  final int datSanId;
  final int sanId;
  final String tenSan;
  final DateTime? ngay;
  final int khungGioMauId;
  final String gioBatDau;
  final String gioKetThuc;
  final double gia;

  ChiTietDatSan({
    this.id = 0,
    this.datSanId = 0,
    this.sanId = 0,
    this.tenSan = '',
    this.ngay,
    this.khungGioMauId = 0,
    this.gioBatDau = '',
    this.gioKetThuc = '',
    this.gia = 0,
  });

  factory ChiTietDatSan.fromJson(Map<String, dynamic> json) {
    return ChiTietDatSan(
      id: _intTuJson(json['id']),
      datSanId: _intTuJson(json['dat_san_id'] ?? json['datSanId']),
      sanId: _intTuJson(json['san_id'] ?? json['sanId']),
      tenSan: '${json['ten_san'] ?? json['tenSan'] ?? json['ten'] ?? ''}',
      ngay: _dateTuJson(json['ngay'] ?? json['ngay_dat'] ?? json['ngayDat']),
      khungGioMauId: _intTuJson(json['khung_gio_mau_id'] ?? json['khungGioMauId']),
      gioBatDau: _catGio(json['gio_bat_dau'] ?? json['bat_dau'] ?? json['gioBatDau']),
      gioKetThuc: _catGio(json['gio_ket_thuc'] ?? json['ket_thuc'] ?? json['gioKetThuc']),
      gia: _doubleTuJson(json['gia']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dat_san_id': datSanId,
      'san_id': sanId,
      'ten_san': tenSan,
      'ngay': ngay?.toIso8601String(),
      'khung_gio_mau_id': khungGioMauId,
      'gio_bat_dau': gioBatDau,
      'gio_ket_thuc': gioKetThuc,
      'gia': gia,
    };
  }

  String get ngayText => _catNgay(ngay?.toIso8601String());
}

class DatSan {
  final int id;
  final int nguoiDungId;
  final int coSoId;
  final String tenCoSo;
  final String diaChi;
  final String phuongXa;
  final String tinhThanh;
  final int? khuyenMaiId;
  final int trangThai;
  final double tongTien;
  final double tienGiam;
  final double thanhTien;
  final double tienCoc;
  final double daThanhToan;
  final DateTime? thoiGianHetHan;
  final String lyDoHuy;
  final int nguoiHuyId;
  final DateTime? thoiGianHuy;
  final String ghiChu;
  final DateTime? ngayTao;
  final String phuongThuc;
  final int? trangThaiThanhToan;
  final int? loaiThanhToan;
  final List<ChiTietDatSan> chiTiet;

  DatSan({
    required this.id,
    this.nguoiDungId = 0,
    this.coSoId = 0,
    this.tenCoSo = '',
    this.diaChi = '',
    this.phuongXa = '',
    this.tinhThanh = '',
    this.khuyenMaiId,
    this.trangThai = 0,
    this.tongTien = 0,
    this.tienGiam = 0,
    this.thanhTien = 0,
    this.tienCoc = 0,
    this.daThanhToan = 0,
    this.thoiGianHetHan,
    this.lyDoHuy = '',
    this.nguoiHuyId = 0,
    this.thoiGianHuy,
    this.ghiChu = '',
    this.ngayTao,
    this.phuongThuc = '',
    this.trangThaiThanhToan,
    this.loaiThanhToan,
    this.chiTiet = const [],
  });

  bool get dangGiuCho => trangThai == 0;
  bool get daXacNhan => trangThai == 1;
  bool get daHuy => trangThai == 2;
  bool get hetHan => trangThai == 3;
  bool get hoanThanh => trangThai == 4;
  bool get coTheHuyGiuCho => trangThai == 0 && daThanhToan <= 0;

  double get conLai {
    final tong = thanhTien > 0 ? thanhTien : tongTien;
    final value = tong - daThanhToan;
    return value < 0 ? 0 : value;
  }

  String get tenTrangThai {
    if (trangThai == 0) return 'Giữ chỗ';
    if (trangThai == 1) return 'Đã xác nhận';
    if (trangThai == 2) return 'Đã hủy';
    if (trangThai == 3) return 'Hết hạn';
    if (trangThai == 4) return 'Hoàn thành';
    return 'Không rõ';
  }

  String get trangThaiHienThi => tenTrangThai;

  factory DatSan.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    final coSo = data['co_so'] is Map ? Map<String, dynamic>.from(data['co_so']) : <String, dynamic>{};
    final rawChiTiet = data['chi_tiet'] ?? data['chiTiet'] ?? data['danh_sach_chi_tiet'] ?? data['slots'];
    final dsChiTiet = <ChiTietDatSan>[];

    if (rawChiTiet is List) {
      for (final item in rawChiTiet) {
        if (item is Map) {
          dsChiTiet.add(ChiTietDatSan.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return DatSan(
      id: _intTuJson(data['id'] ?? data['dat_san_id'] ?? data['datSanId']),
      nguoiDungId: _intTuJson(data['nguoi_dung_id'] ?? data['nguoiDungId']),
      coSoId: _intTuJson(coSo['id'] ?? data['co_so_id'] ?? data['coSoId']),
      tenCoSo: '${coSo['ten'] ?? coSo['ten_co_so'] ?? data['ten_co_so'] ?? data['tenCoSo'] ?? data['co_so_ten'] ?? ''}',
      diaChi: '${coSo['dia_chi'] ?? data['dia_chi'] ?? ''}',
      phuongXa: '${coSo['phuong_xa'] ?? data['phuong_xa'] ?? ''}',
      tinhThanh: '${coSo['tinh_thanh'] ?? data['tinh_thanh'] ?? ''}',
      khuyenMaiId: data['khuyen_mai_id'] == null ? null : _intTuJson(data['khuyen_mai_id']),
      trangThai: _intTuJson(data['trang_thai'] ?? data['trangThai']),
      tongTien: _doubleTuJson(data['tong_tien'] ?? data['tongTien']),
      tienGiam: _doubleTuJson(data['tien_giam'] ?? data['tienGiam']),
      thanhTien: _doubleTuJson(data['thanh_tien'] ?? data['thanhTien']),
      tienCoc: _doubleTuJson(data['tien_coc'] ?? data['tienCoc']),
      daThanhToan: _doubleTuJson(data['da_thanh_toan'] ?? data['daThanhToan']),
      thoiGianHetHan: _dateTuJson(data['thoi_gian_het_han'] ?? data['thoiGianHetHan']),
      lyDoHuy: '${data['ly_do_huy'] ?? data['lyDoHuy'] ?? ''}',
      nguoiHuyId: _intTuJson(data['nguoi_huy_id'] ?? data['nguoiHuyId']),
      thoiGianHuy: _dateTuJson(data['thoi_gian_huy'] ?? data['thoiGianHuy']),
      ghiChu: '${data['ghi_chu'] ?? data['ghiChu'] ?? ''}',
      ngayTao: _dateTuJson(data['ngay_tao'] ?? data['ngayTao']),
      phuongThuc: '${data['phuong_thuc'] ?? data['phuongThuc'] ?? ''}',
      trangThaiThanhToan: data['trang_thai_thanh_toan'] == null ? null : _intTuJson(data['trang_thai_thanh_toan']),
      loaiThanhToan: data['loai_thanh_toan'] == null ? null : _intTuJson(data['loai_thanh_toan']),
      chiTiet: dsChiTiet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nguoi_dung_id': nguoiDungId,
      'co_so_id': coSoId,
      'ten_co_so': tenCoSo,
      'dia_chi': diaChi,
      'phuong_xa': phuongXa,
      'tinh_thanh': tinhThanh,
      'khuyen_mai_id': khuyenMaiId,
      'trang_thai': trangThai,
      'tong_tien': tongTien,
      'tien_giam': tienGiam,
      'thanh_tien': thanhTien,
      'tien_coc': tienCoc,
      'da_thanh_toan': daThanhToan,
      'thoi_gian_het_han': thoiGianHetHan?.toIso8601String(),
      'ly_do_huy': lyDoHuy,
      'ghi_chu': ghiChu,
      'ngay_tao': ngayTao?.toIso8601String(),
      'phuong_thuc': phuongThuc,
      'trang_thai_thanh_toan': trangThaiThanhToan,
      'loai_thanh_toan': loaiThanhToan,
      'chi_tiet': chiTiet.map((e) => e.toJson()).toList(),
    };
  }

  static List<DatSan> listFrom(dynamic data) {
    final list = data is Map ? (data['data'] ?? data['items'] ?? data['lich_su'] ?? []) : data;
    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => DatSan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
