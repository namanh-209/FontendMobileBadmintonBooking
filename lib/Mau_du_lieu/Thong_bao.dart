class ThongBao {
  final int id;
  final int? nguoiDungId;
  final String tieuDe;
  final String noiDung;
  final String? loaiThongBao;
  final int daDoc;
  final String? duongDan;
  final String? ngayTao;

  ThongBao({
    required this.id,
    this.nguoiDungId,
    required this.tieuDe,
    required this.noiDung,
    this.loaiThongBao,
    required this.daDoc,
    this.duongDan,
    this.ngayTao,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nguoiDungId: json['nguoi_dung_id'] == null
          ? null
          : int.tryParse(json['nguoi_dung_id'].toString()),
      tieuDe: json['tieu_de']?.toString() ?? 'Thông báo',
      noiDung: json['noi_dung']?.toString() ?? '',
      loaiThongBao: json['loai_thong_bao']?.toString(),
      daDoc: int.tryParse(json['da_doc'].toString()) ?? 0,
      duongDan: json['duong_dan']?.toString(),
      ngayTao: json['ngay_tao']?.toString() ??
          json['created_at']?.toString() ??
          json['createdAt']?.toString(),
    );
  }
}