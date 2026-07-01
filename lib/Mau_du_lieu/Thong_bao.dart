class ThongBao {
  final int id;
  final int nguoiDungId;
  final String tieuDe;
  final String noiDung;
  final String loaiThongBao;
  final int daDoc;
  final String duongDan;
  final String ngayTao;

  ThongBao({
    required this.id,
    required this.nguoiDungId,
    required this.tieuDe,
    required this.noiDung,
    required this.loaiThongBao,
    required this.daDoc,
    required this.duongDan,
    required this.ngayTao,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      id: json['id'] ?? 0,
      nguoiDungId: json['nguoi_dung_id'] ?? 0,
      tieuDe: json['tieu_de'] ?? '',
      noiDung: json['noi_dung'] ?? '',
      loaiThongBao: json['loai_thong_bao'] ?? '',
      daDoc: json['da_doc'] ?? 0,
      duongDan: json['duong_dan'] ?? '',
      ngayTao: json['ngay_tao'] ?? '',
    );
  }
}