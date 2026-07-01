class DanhGia {
  final int id;
  final int soSao;
  final String noiDung;
  final String tenNguoiDung;
  final String ngayTao;

  DanhGia({
    required this.id,
    required this.soSao,
    required this.noiDung,
    required this.tenNguoiDung,
    required this.ngayTao,
  });

  factory DanhGia.fromJson(Map<String, dynamic> json) {
    return DanhGia(
      id: json['id'] ?? 0,
      soSao: json['so_sao'] ?? 0,
      noiDung: json['noi_dung'] ?? '',
      tenNguoiDung: json['ten_nguoi_dung'] ?? json['ho_ten'] ?? 'Người dùng',
      ngayTao: json['ngay_tao'] ?? '',
    );
  }
}