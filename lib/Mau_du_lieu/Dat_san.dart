class ChiTietDatSan {
  final int sanId;
  final String tenSan;
  final String ngay;
  final int khungGioMauId;
  final String gioBatDau;
  final String gioKetThuc;
  final double gia;

  ChiTietDatSan({
    this.sanId = 0,
    this.tenSan = '',
    this.ngay = '',
    this.khungGioMauId = 0,
    this.gioBatDau = '',
    this.gioKetThuc = '',
    this.gia = 0,
  });

  factory ChiTietDatSan.fromJson(Map<String, dynamic> json) {
    return ChiTietDatSan(
      sanId: _toInt(json['san_id'] ?? json['sanId']) ?? 0,
      tenSan: (json['ten_san'] ?? json['tenSan'] ?? json['ten'] ?? '').toString(),
      ngay: _catNgay(json['ngay'] ?? json['ngay_dat'] ?? json['ngayDat']),
      khungGioMauId: _toInt(json['khung_gio_mau_id'] ?? json['khungGioMauId']) ?? 0,
      gioBatDau: _catGio(json['gio_bat_dau'] ?? json['gioBatDau']),
      gioKetThuc: _catGio(json['gio_ket_thuc'] ?? json['gioKetThuc']),
      gia: _toDouble(json['gia']) ?? 0,
    );
  }

  static String _catNgay(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 10) return text.substring(0, 10);
    return text;
  }

  static String _catGio(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.length >= 5) return text.substring(0, 5);
    return text;
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

class DatSan {
  final int id;
  final int trangThai;
  final double tongTien;
  final double thanhTien;
  final double tienCoc;
  final double daThanhToan;
  final double conLai;
  final String thoiGianHetHan;
  final String ngayTao;
  final String lyDoHuy;
  final String phuongThuc;
  final int? trangThaiThanhToan;
  final int? loaiThanhToan;
  final int coSoId;
  final String tenCoSo;
  final String diaChi;
  final String phuongXa;
  final String tinhThanh;
  final List<ChiTietDatSan> chiTiet;

  DatSan({
    this.id = 0,
    this.trangThai = 0,
    this.tongTien = 0,
    this.thanhTien = 0,
    this.tienCoc = 0,
    this.daThanhToan = 0,
    this.conLai = 0,
    this.thoiGianHetHan = '',
    this.ngayTao = '',
    this.lyDoHuy = '',
    this.phuongThuc = '',
    this.trangThaiThanhToan,
    this.loaiThanhToan,
    this.coSoId = 0,
    this.tenCoSo = '',
    this.diaChi = '',
    this.phuongXa = '',
    this.tinhThanh = '',
    this.chiTiet = const [],
  });

  factory DatSan.fromJson(Map<String, dynamic> json) {
    final coSo = json['co_so'] is Map ? Map<String, dynamic>.from(json['co_so']) : <String, dynamic>{};
    final chiTietJson = json['chi_tiet'] ?? json['chiTiet'] ?? [];

    return DatSan(
      id: _toInt(json['id'] ?? json['dat_san_id'] ?? json['datSanId']) ?? 0,
      trangThai: _toInt(json['trang_thai'] ?? json['trangThai']) ?? 0,
      tongTien: _toDouble(json['tong_tien'] ?? json['tongTien']) ?? 0,
      thanhTien: _toDouble(json['thanh_tien'] ?? json['thanhTien']) ?? 0,
      tienCoc: _toDouble(json['tien_coc'] ?? json['tienCoc']) ?? 0,
      daThanhToan: _toDouble(json['da_thanh_toan'] ?? json['daThanhToan']) ?? 0,
      conLai: _toDouble(json['con_lai'] ?? json['conLai']) ?? 0,
      thoiGianHetHan: (json['thoi_gian_het_han'] ?? json['thoiGianHetHan'] ?? '').toString(),
      ngayTao: (json['ngay_tao'] ?? json['ngayTao'] ?? '').toString(),
      lyDoHuy: (json['ly_do_huy'] ?? json['lyDoHuy'] ?? '').toString(),
      phuongThuc: (json['phuong_thuc'] ?? json['phuongThuc'] ?? '').toString(),
      trangThaiThanhToan: _toInt(json['trang_thai_thanh_toan'] ?? json['trangThaiThanhToan']),
      loaiThanhToan: _toInt(json['loai_thanh_toan'] ?? json['loaiThanhToan']),
      coSoId: _toInt(coSo['id'] ?? json['co_so_id'] ?? json['coSoId']) ?? 0,
      tenCoSo: (coSo['ten'] ?? coSo['ten_co_so'] ?? json['ten_co_so'] ?? '').toString(),
      diaChi: (coSo['dia_chi'] ?? json['dia_chi'] ?? '').toString(),
      phuongXa: (coSo['phuong_xa'] ?? json['phuong_xa'] ?? '').toString(),
      tinhThanh: (coSo['tinh_thanh'] ?? json['tinh_thanh'] ?? '').toString(),
      chiTiet: chiTietJson is List
          ? chiTietJson
              .whereType<Map>()
              .map((e) => ChiTietDatSan.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  String get trangThaiHienThi {
    if (trangThai == 1) return 'Đã đặt';
    if (trangThai == 2) return 'Đã hủy';
    return 'Đang giữ chỗ';
  }

  bool get coTheHuyGiuCho {
    return trangThai == 0 && daThanhToan <= 0;
  }

  static List<DatSan> listFrom(dynamic data) {
    final list = data is Map ? (data['data'] ?? data['items'] ?? data['lich_su'] ?? []) : data;
    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => DatSan.fromJson(Map<String, dynamic>.from(e)))
        .toList();
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
